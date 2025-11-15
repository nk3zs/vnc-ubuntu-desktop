# Chọn base image Ubuntu 22.04
FROM ubuntu:22.04

# Tránh tương tác khi cài đặt gói
ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật và cài các gói cơ bản + build tools + python
RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    openssh-server \
    ca-certificates \
    build-essential \
    python3 \
    python3-pip \
    xauth \
    lsb-release \
    libxext6 \
    libxmuu1 \
    libxml2 \
    htop \
    networkd-dispatcher \
    ssh-import-id \
    && rm -rf /var/lib/apt/lists/*

# Cài Node.js v18
RUN curl -fsSL https://nodejs.org/dist/v18.19.1/node-v18.19.1-linux-x64.tar.xz -o node.tar.xz \
    && tar -xf node.tar.xz -C /usr/local --strip-components=1 \
    && rm node.tar.xz \
    && node -v \
    && npm -v

# Tạo user ubuntu và add vào sudo
RUN useradd -m -s /bin/bash ubuntu \
    && echo "ubuntu:ubuntu" | chpasswd \
    && adduser ubuntu sudo

# Chuẩn bị SSH
RUN mkdir -p /var/run/sshd

# Cài Wetty (web terminal)
RUN npm install -g wetty

# Expose port cho Wetty
EXPOSE 3000

# Command để chạy SSH server (Wetty sẽ dùng)
CMD ["/usr/sbin/sshd", "-D"]
