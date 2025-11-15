FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật và cài các gói cần thiết, bao gồm build tools và Python
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

# Gỡ bỏ nodejs cũ nếu có (giải quyết xung đột)
RUN apt-get remove --purge -y nodejs libnode-dev

# Cài đặt Node.js 18 từ NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# Cài đặt Wetty
RUN npm install -g wetty

# Tạo thư mục sshd
RUN mkdir /var/run/sshd

# Cấu hình SSH
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Mở port 80 cho Wetty (Web SSH Terminal)
EXPOSE 80

# Cài đặt và khởi động SSH, sau đó chạy Wetty
CMD service ssh start && wetty --port 80 --ssh-host 127.0.0.1
