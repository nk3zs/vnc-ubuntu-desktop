# ================================
# Ubuntu Desktop (GNOME minimal) + VNC + noVNC
# ================================
FROM ubuntu:22.04

LABEL maintainer="ChatGPT Ubuntu Desktop"

# --- Fix tzdata non-interactive + timezone setup ---
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Ho_Chi_Minh

RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata && \
    dpkg-reconfigure -f noninteractive tzdata

# --- Cài đặt môi trường desktop + VNC + noVNC ---
RUN apt-get install -y \
    sudo wget curl gnupg2 software-properties-common \
    tightvncserver novnc websockify \
    ubuntu-desktop-minimal dbus-x11 xterm xfce4 xfce4-goodies \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Tạo user ubuntu ---
RUN useradd -m -s /bin/bash ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

USER ubuntu
WORKDIR /home/ubuntu

# --- Cấu hình VNC ---
RUN mkdir -p ~/.vnc && \
    echo "ubuntu" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# --- Script start VNC + noVNC ---
RUN echo '#!/bin/bash
vncserver -kill :1 || true
vncserver :1 -geometry 1366x768 -depth 24
sleep 2
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &
echo "✅ Ubuntu Desktop is running at :6080"
tail -f /dev/null
' > ~/start.sh && chmod +x ~/start.sh

# --- Liên kết index.html tới noVNC interface ---
USER root
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# --- Mở port web noVNC ---
EXPOSE 6080

# --- Chạy Ubuntu Desktop VNC ---
CMD ["/home/ubuntu/start.sh"]
