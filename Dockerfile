FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Base
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo wget curl nano htop jq bash net-tools iproute2 openssh-server \
    zram-config ca-certificates supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# Install ShellHub (all-in-one mode)
RUN curl -fsSL https://get.shellhub.io/install.sh | \
    BOOTSTRAP_TOKEN=local INSTALL_MODE=standalone \
    sh

# Fix directories
RUN mkdir -p /var/run/sshd && mkdir -p /etc/shellhub

# ---------- Supervisor config ----------
RUN printf "%s\n" \
"[supervisord]" \
"nodaemon=true" \
"user=root" \
"" \
"[program:shellhub]" \
"command=/usr/bin/shellhub start" \
"autostart=true" \
"autorestart=true" \
"" \
"[program:sshd]" \
"command=/usr/sbin/sshd -D -p 2222" \
"autostart=true" \
"autorestart=true" \
> /etc/supervisor/conf.d/supervisord.conf

# ---------- Start script ----------
RUN printf "%s\n" \
"#!/bin/bash" \
"" \
"# ZRAM" \
"echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null || true" \
"echo 512M > /sys/block/zram0/disksize 2>/dev/null || true" \
"mkswap /dev/zram0 2>/dev/null || true" \
"swapon /dev/zram0 2>/dev/null || true" \
"" \
"# SWAP backup 512MB" \
"SWAPFILE=/swapfile" \
"if [ ! -f \$SWAPFILE ]; then" \
"  fallocate -l 512M \$SWAPFILE || dd if=/dev/zero of=\$SWAPFILE bs=1M count=512" \
"  chmod 600 \$SWAPFILE" \
"  mkswap \$SWAPFILE" \
"  swapon \$SWAPFILE" \
"fi" \
"" \
"# Tune kernel" \
"sysctl -w vm.swappiness=90" \
"sysctl -w vm.vfs_cache_pressure=200" \
"" \
"# Start ShellHub" \
"exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf" \
> /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080 2222
CMD ["/usr/local/bin/start.sh"]
