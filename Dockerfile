# Base: Ubuntu 22.04 (Jammy Jellyfish)
FROM ubuntu:22.04

LABEL maintainer="ChatGPT Ubuntu Desktop Full - GNOME Web"

# Cập nhật hệ thống & cài Ubuntu Desktop GNOME + VNC + noVNC
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ubuntu-desktop-minimal \
        gdm3 \
        tightvncserver novnc websockify \
        sudo wget curl dbus-x11 xterm && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Tạo user ubuntu
RUN useradd -m -s /bin/bash ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

USER ubuntu
WORKDIR /home/ubuntu

# Cấu hình VNC
RUN mkdir -p ~/.vnc && \
    echo "ubuntu" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd && \
    echo '#!/bin/bash\n\
vncserver -kill :1 || true\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
websockify --web=/usr/share/novnc/ 6080 localhost:5901\n\
tail -f /dev/null' > ~/start.sh && chmod +x ~/start.sh

EXPOSE 6080
CMD ["/home/ubuntu/start.sh"]
