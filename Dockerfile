FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt các công cụ cơ bản
RUN apt-get update && apt-get install -y \
    sudo wget curl nano htop bash openssh-server ca-certificates \
    build-essential python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt NodeJS 18 và npm
RUN curl -fsSL https://nodejs.org/dist/v18.19.1/node-v18.19.1-linux-x64.tar.xz -o node.tar.xz && \
    tar -xf node.tar.xz -C /usr/local --strip-components=1 && \
    rm node.tar.xz && \
    node -v && npm -v

# Tạo user
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd && \
    adduser ubuntu sudo

# Cài đặt Wetty (phiên bản mới nhất)
RUN npm install -g wetty

# Tạo thư mục SSH
RUN mkdir -p /var/run/sshd

# Mở port 8080 cho Web Terminal
EXPOSE 8080

# Lệnh khởi động SSH và Wetty
CMD service ssh start && \
    wetty --port 8080 --base / --ssh-host 127.0.0.1 --ssh-port 22
