FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Bangkok \
    SHELLHUB_INSTALL_MODE=standalone

# ---------- Base system + tools ----------
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo wget curl ca-certificates gnupg2 apt-transport-https \
    bash bash-completion coreutils procps iproute2 net-tools iputils-ping \
    nano vim htop jq unzip tar git rsync locales tzdata \
    openssh-server screen tmux supervisor haveged openjdk-17-jre-headless \
    openjdk-11-jre-headless ca-certificates \
    zram-config psmisc iotop rsync unzip curl \
    && rm -rf /var/lib/apt/lists/*

# locales + timezone
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Create a user for SSH and sudo access
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# ---------- Install ShellHub (standalone) ----------
# ShellHub installer will create necessary services under /usr/bin/shellhub
# Use non-interactive install; if the real script changes, this may need update.
RUN curl -fsSL https://get.shellhub.io/install.sh -o /tmp/install-shellhub.sh && \
    chmod +x /tmp/install-shellhub.sh && \
    # set local/standalone mode via env; installer will install binary under /usr/bin
    BOOTSTRAP_TOKEN=local INSTALL_MODE=standalone sh /tmp/install-shellhub.sh || true && \
    rm -f /tmp/install-shellhub.sh || true

# Ensure minimal dirs exist
RUN mkdir -p /var/run/sshd /etc/shellhub /var/lib/shellhub || true

# ---------- Supervisor config ----------
RUN mkdir -p /etc/supervisor/conf.d
RUN printf "%s\n" \
"[supervisord]" \
"nodaemon=true" \
"user=root" \
"" \
"[program:sshd]" \
"command=/usr/sbin/sshd -D -p 2222" \
"autostart=true" \
"autorestart=true" \
"" \
"[program:shellhub]" \
"command=/usr/bin/shellhub start" \
"autostart=true" \
"autorestart=true" \
"" \
"[program:haveged]" \
"command=/usr/sbin/haveged -w 1024" \
"autostart=true" \
"autorestart=true" \
> /etc/supervisor/conf.d/supervisord.conf

# ---------- Helper: Minecraft installer + management ----------
RUN mkdir -p /opt/minecraft && chown ubuntu:ubuntu /opt/minecraft
RUN printf "%s\n" \
"#!/bin/bash" \
"# install_minecraft.sh - download PaperMC latest and create start script" \
"set -e" \
"WORKDIR=/opt/minecraft" \
"mkdir -p \$WORKDIR" \
"cd \$WORKDIR" \
"echo 'Downloading latest Paper build info...'" \
"API=https://api.papermc.io/v2/projects/paper" \
"VERSION=$(curl -s \$API | jq -r '.versions[-1]')" \
"BUILD=$(curl -s \$API/versions/\$VERSION/builds | jq -r '.builds[-1].build')" \
"JARURL=\$(curl -s \$API/versions/\$VERSION/builds/\$BUILD | jq -r '.downloads.application.url')" \
"wget -O paper.jar \$JARURL" \
"cat > start.sh <<'EOL'" \
"#!/bin/bash" \
"cd /opt/minecraft" \
"if [ ! -f eula.txt ]; then echo 'eula=true' > eula.txt; fi" \
"java -Xms512M -Xmx1G -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:G1HeapRegionSize=4M -XX:+UseStringDeduplication -jar paper.jar nogui" \
"EOL" \
"chmod +x start.sh" \
"chown -R ubuntu:ubuntu \$WORKDIR" \
> /usr/local/bin/install_minecraft.sh

RUN chmod +x /usr/local/bin/install_minecraft.sh

# ---------- Start script: zram, swap, sysctl, optimizations ----------
RUN printf "%s\n" \
"#!/bin/bash" \
"set -e" \
"" \
"# ---- Disable apt timers ----" \
"rm -f /etc/cron.daily/apt-* 2>/dev/null || true" \
"systemctl disable --now apt-daily.timer apt-daily-upgrade.timer 2>/dev/null || true" \
"" \
"# ---- kernel tuning ----" \
"sysctl -w vm.swappiness=90 || true" \
"sysctl -w vm.vfs_cache_pressure=200 || true" \
"sysctl -w fs.file-max=100000 || true" \
"" \
"# ---- Create handy aliases for ubuntu user ----" \
"cat >> /etc/profile.d/99-helpers.sh <<'EOF'" \
"alias update='sudo apt update && sudo apt upgrade -y'" \
"alias installmc='sudo /usr/local/bin/install_minecraft.sh && echo \"Minecraft installed at /opt/minecraft. Start with: sudo /opt/minecraft/start.sh\"'" \
"EOF" \
"chmod +x /etc/profile.d/99-helpers.sh" \
"" \
"# ---- Start supervisord (shellhub, sshd, haveged) ----" \
"exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf" \
> /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

# Expose necessary ports (web panel, SSH)
EXPOSE 8080 2222 25565

# Entrypoint command to start processes
CMD ["/usr/local/bin/start.sh"]
