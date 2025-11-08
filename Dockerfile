# Start from Ubuntu base image
FROM ubuntu:22.04

LABEL maintainer="ChatGPT Ubuntu Desktop"

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    sudo wget curl gnupg2 software-properties-common \
    tightvncserver novnc websockify \
    ubuntu-desktop-minimal \
    dbus-x11 xterm && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create user and set password
RUN useradd -m -s /bin/bash ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

# Switch to user "ubuntu"
USER ubuntu
WORKDIR /home/ubuntu

# Set up VNC server
RUN mkdir -p ~/.vnc && \
    echo "ubuntu" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Script to start VNC server and noVNC
RUN echo '#!/bin/bash\n\
vncserver -kill :1 || true\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
websockify --web=/usr/share/novnc/ 6080 localhost:5901\n\
tail -f /dev/null' > ~/start.sh && chmod +x ~/start.sh

# Expose the necessary ports
EXPOSE 6080

# Set the command to run the VNC server and websockify
CMD ["/home/ubuntu/start.sh"]
