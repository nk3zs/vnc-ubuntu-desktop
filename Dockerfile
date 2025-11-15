FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base packages
RUN apt-get update && apt-get install -y \
    sudo curl wget nano htop bash openssh-server \
    nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# Setup SSH
RUN mkdir -p /var/run/sshd

# Install Wetty (web terminal)
RUN npm install -g wetty

# Expose port
EXPOSE 8080

# Start script
CMD service ssh start && \
    wetty --port 8080 --base / --ssh-host 127.0.0.1 --ssh-port 22
