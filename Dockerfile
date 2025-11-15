FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    USER=ubuntu \
    PASSWORD=ubuntu \
    DISPLAY=:1

# ---------------------------
# BASE SYSTEM
# ---------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo wget curl nano supervisor dbus-x11 \
    locales ca-certificates net-tools pulseaudio \
    x11-xserver-utils xvfb xauth x11vnc \
    openbox tint2 obconf \
    websockify novnc \
    firefox \
    zram-tools \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$PASSWORD" | chpasswd && \
    adduser $USER sudo

# ---------------------------
# CONFIG OPENBOX + PANEL
# ---------------------------
RUN mkdir -p /home/ubuntu/.config/openbox
RUN printf "%s\n" \
"tint2 &" \
"nitrogen --restore &" \
"setxkbmap us &" \
"feh --bg-scale /usr/share/backgrounds/xfce/xfce-blue.jpg" \
> /home/ubuntu/.config/openbox/autostart

RUN chown -R ubuntu:ubuntu /home/ubuntu/.config

# ---------------------------
# ENABLE ZRAM (512MB)
# ---------------------------
RUN printf "%s\n" \
"ALGO=lz4" \
"SIZE=512" \
> /etc/default/zramswap

# ---------------------------
# SUPERVISOR CONFIG
# ---------------------------
RUN printf "%s\n" \
"[supervisord]" \
"nodaemon=true" \
"user=root" \
"" \
"[program:xvfb]" \
"command=/usr/bin/Xvfb :1 -screen 0 1920x1080x24 +extension RANDR" \
"priority=1" \
"autostart=true" \
"autorestart=true" \
"" \
"[program:openbox]" \
"command=/bin/bash -lc \"export DISPLAY=:1; su - ubuntu -c 'dbus-launch openbox-session'\"" \
"priority=2" \
"autostart=true" \
"autorestart=true" \
"startsecs=3" \
"" \
"[program:x11vnc]" \
"command=/bin/bash -lc \"sleep 2 && x11vnc -display :1 -nopw -forever -shared -rfbport 5900\"" \
"priority=3" \
"autostart=true" \
"autorestart=true" \
"" \
"[program:novnc]" \
"command=websockify --web=/usr/share/novnc/ 6080 localhost:5900" \
"priority=4" \
"autostart=true" \
"autorestart=true" \
"" \
"[program:pulseaudio]" \
"command=pulseaudio --system --disallow-exit --disallow-module-loading --exit-idle-time=-1" \
"priority=5" \
"autostart=true" \
"autorestart=true" \
> /etc/supervisor/conf.d/supervisord.conf

# ---------------------------
# STARTUP SCRIPT
# ---------------------------
RUN printf "%s\n" \
"#!/bin/bash" \
"" \
"rm -f /etc/cron.daily/apt-compat 2>/dev/null || true" \
"" \
"SWAPFILE=/swapfile" \
"if [ ! -f \"\$SWAPFILE\" ]; then" \
"  fallocate -l 512M \$SWAPFILE || dd if=/dev/zero of=\$SWAPFILE bs=1M count=512" \
"  chmod 600 \$SWAPFILE" \
"  mkswap \$SWAPFILE" \
"  swapon \$SWAPFILE" \
"fi" \
"" \
"systemctl disable --now zramswap.service 2>/dev/null || true" \
"zramswap start" \
"" \
"sysctl -w vm.swappiness=10" \
"sysctl -w vm.vfs_cache_pressure=50" \
"sysctl -w kernel.sched_autogroup_enabled=1" \
"" \
"export DISPLAY=:1" \
"exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf" \
> /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 6080 5900 4713

CMD ["/usr/local/bin/start.sh"]
