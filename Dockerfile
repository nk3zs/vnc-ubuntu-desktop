FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Node 18 (để tránh lỗi syntax)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && apt-get install -y \
    nodejs \
    sudo curl wget nano htop bash openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# Setup SSH
RUN mkdir -p /var/run/sshd

# Install stable Wetty (fixed version)
RUN npm install -g wetty@1.4.0

# Expose port
EXPOSE 8080

CMD service ssh start && \
    wetty --port 8080 --base / --ssh-host 127.0.0.1 --ssh-port 22
