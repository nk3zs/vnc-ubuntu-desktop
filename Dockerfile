FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Base tools
RUN apt-get update && apt-get install -y \
    sudo wget curl nano htop bash openssh-server \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# SSH setup
RUN mkdir -p /var/run/sshd

# Install Wetty (Web SSH)
RUN npm install -g wetty

# Expose HTTP port
EXPOSE 8080

# Start web terminal and SSH
CMD service ssh start && \
    wetty --port 8080 --base / --ssh-host 127.0.0.1 --ssh-port 22
