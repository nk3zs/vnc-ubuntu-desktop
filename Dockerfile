FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Base tools
RUN apt-get update && apt-get install -y \
    sudo wget curl nano htop bash openssh-server ca-certificates xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Node 18 manually (WORKS 100%)
RUN curl -fsSL https://nodejs.org/dist/v18.19.1/node-v18.19.1-linux-x64.tar.xz -o node.tar.xz && \
    tar -xf node.tar.xz -C /usr/local --strip-components=1 && \
    rm node.tar.xz && \
    node -v && npm -v

# Create user
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# SSH
RUN mkdir -p /var/run/sshd

# Install stable Wetty
RUN npm install -g wetty@1.4.0

# Expose port
EXPOSE 8080

CMD service ssh start && \
    wetty --port 8080 --base / --ssh-host 127.0.0.1 --ssh-port 22
