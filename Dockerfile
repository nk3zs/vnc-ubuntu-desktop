FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base packages first
RUN apt-get update && apt-get install -y \
    sudo curl wget nano htop bash openssh-server ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node 18 properly
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    node -v && npm -v

# Create user
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# SSH config
RUN mkdir -p /var/run/sshd

# Install Wetty stable version
RUN npm install -g wetty@1.4.0

# Expose port
EXPOSE 8080

# Start command
CMD service ssh start && \
    wetty --port 8080 --base / --ssh-host 127.0.0.1 --ssh-port 22
