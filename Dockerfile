# ============================
# Ubuntu Web Desktop One-File
# ============================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    USER=ubuntu \
    PASSWORD=ubuntu

# ---------- Cài hệ thống + desktop nhẹ + noVNC ----------
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo wget curl nano supervisor \
    locales ca-certificates dbus-x11 net-tools \
    x11-xserver-utils xvfb xauth x11vnc \
    xfce4 xfce4-terminal xfce4-session xfce4-panel \
    websockify novnc \
    && rm -rf /var/lib/apt/lists/*

# Tạo user ubuntu
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$PASSWORD" | chpasswd && \
    adduser $USER sudo

# ============================
#  Gộp file supervisord.conf vào Dockerfile
# ============================
RUN mkdir -p /etc/supervisor/conf.d
RUN bash -c 'cat > /etc/supervisor/conf.d/supervisord.conf << "EOF"
[supervisord]
nodaemon=true

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 1280x720x16
autostart=true
autorestart=true

[program:xfce]
command=/bin/bash -lc "export DISPLAY=:1; su - ubuntu -c 'startxfce4'"
autostart=true
autorestart=true
startsecs=5

[program:x11vnc]
command=/usr/bin/x11vnc -display :1 -forever -nopw -shared -rfbport 5900
autostart=true
autorestart=true

[program:novnc]
command=/usr/bin/websockify --web=/usr/share/novnc/ 6080 localhost:5900
autostart=true
autorestart=true
EOF'

# ============================
#  Gộp start.sh vào Dockerfile
# ============================
RUN bash -c 'cat > /usr/local/bin/start.sh << "EOF"
#!/bin/bash

# Disable apt timers
rm -f /etc/cron.daily/apt-compat 2>/dev/null || true

# Swap 512MB để máy RAM yếu đỡ lag
SWAPFILE=/swapfile
if [ ! -f "$SWAPFILE" ]; then
  fallocate -l 512M $SWAPFILE || dd if=/dev/zero of=$SWAPFILE bs=1M count=512
  chmod 600 $SWAPFILE
  mkswap $SWAPFILE
  swapon $SWAPFILE
fi

# Tối ưu kernel
sysctl -w vm.swappiness=90
sysctl -w vm.vfs_cache_pressure=200

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
EOF'

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 6080 5900

CMD ["/usr/local/bin/start.sh"]
