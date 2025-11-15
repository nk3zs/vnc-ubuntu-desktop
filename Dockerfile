FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# --------- CÀI PACKAGES CẦN THIẾT NHẸ NHẤT ----------
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo wget curl nano supervisor \
    dbus-x11 x11-xserver-utils xvfb xauth \
    openbox tint2 obconf \
    x11vnc \
    zram-config \
    qemu-kvm qemu-utils bridge-utils \
    && rm -rf /var/lib/apt/lists/*

# --------- TẠO USER ----------
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# --------- SUPERVISOR CONFIG ----------
RUN printf "%s\n" \
"[supervisord]" \
"nodaemon=true" \
"user=root" \
"" \
"[program:xvfb]" \
"command=/usr/bin/Xvfb :1 -screen 0 1280x720x16" \
"autostart=true" \
"autorestart=true" \
"" \
"[program:openbox]" \
"command=/bin/bash -lc \"export DISPLAY=:1; su - ubuntu -c 'openbox-session'\"" \
"autostart=true" \
"autorestart=true" \
"startsecs=3" \
"" \
"[program:tint2]" \
"command=/bin/bash -lc \"export DISPLAY=:1; su - ubuntu -c 'tint2'\"" \
"autostart=true" \
"autorestart=true" \
"startsecs=2" \
"" \
"[program:x11vnc]" \
"command=/usr/bin/x11vnc -display :1 -forever -nopw -shared -rfbport 5900" \
"autostart=true" \
"autorestart=true" \
> /etc/supervisor/conf.d/supervisord.conf

# --------- START.SH ---------
RUN printf "%s\n" \
"#!/bin/bash" \
"" \
"# ===== ZRAM (RAM nén x3) =====" \
"echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null || true" \
"echo 512M > /sys/block/zram0/disksize 2>/dev/null || true" \
"mkswap /dev/zram0 2>/dev/null || true" \
"swapon /dev/zram0 2>/dev/null || true" \
"" \
"# ===== SWAP 512MB =====" \
"SWAPFILE=/swapfile" \
"if [ ! -f \$SWAPFILE ]; then" \
"  fallocate -l 512M \$SWAPFILE || dd if=/dev/zero of=\$SWAPFILE bs=1M count=512" \
"  chmod 600 \$SWAPFILE" \
"  mkswap \$SWAPFILE" \
"  swapon \$SWAPFILE" \
"fi" \
"" \
"# ===== SYSCTL TỐI ƯU =====" \
"sysctl -w vm.swappiness=90" \
"sysctl -w vm.vfs_cache_pressure=200" \
"" \
"exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf" \
> /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5900

CMD ["/usr/local/bin/start.sh"]
