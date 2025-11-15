# Dockerfile - ubuntu web desktop nhẹ (LXDE + x11vnc + web noVNC)
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    USER=ubuntu \
    PASSWORD=ubuntu

# core packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    wget \
    ca-certificates \
    locales \
    dbus-x11 \
    x11-xserver-utils \
    xauth \
    xvfb \
    x11vnc \
    xfce4 \
    xfce4-terminal \
    xfce4-panel \
    xfce4-session \
    lightdm \
    openbox \
    pcmanfm \
    net-tools \
    curl \
    python3 \
    python3-pip \
    supervisor \
    websockify \
    novnc \
    && rm -rf /var/lib/apt/lists/*

# create user
RUN useradd -m -s /bin/bash $USER && echo "$USER:$PASSWORD" | chpasswd && adduser $USER sudo

# Setup noVNC folder (some distros package novnc differently; ensure webroot exists)
RUN mkdir -p /opt/novnc && \
    ln -s /usr/share/novnc /opt/novnc 2>/dev/null || true

# Supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 6080 5900

CMD ["/usr/local/bin/start.sh"]
