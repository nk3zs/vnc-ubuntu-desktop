FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt base packages
RUN apt-get update && apt-get install -y \
    sudo wget curl nano htop bash openssh-server ca-certificates xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Cài Node.js 18 (chạy được npm)
RUN curl -fsSL https://nodejs.org/dist/v18.19.1/node-v18.19.1-linux-x64.tar.xz -o node.tar.xz && \
    tar -xf node.tar.xz -C /usr/local --strip-components=1 && \
    rm node.tar.xz && \
    node -v && npm -v

# Tạo user ubuntu
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# Tạo thư mục SSH
RUN mkdir -p /var/run/sshd

# Cài Wetty phiên bản mới nhất (4.x)
RUN npm install -g wetty

# Expose port 8080 cho web terminal
EXPOSE 8080

# Start SSH và Wetty
CMD service ssh start && \
    wetty --port 8080 --base / --ssh-host 127.0.0.1 --ssh-port 22
