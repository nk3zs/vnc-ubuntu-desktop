FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật và cài đặt các gói cần thiết
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
    ssh-import-id \
    && rm -rf /var/lib/apt/lists/*

# Nếu Node.js đã được cài trước đó, ta sẽ chỉ cần cài lại từ NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# Cài Wetty
RUN npm install -g wetty

# Tạo thư mục cho SSH
RUN mkdir /var/run/sshd

# Cấu hình SSH cho phép login với user root
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Mở port 80 cho Wetty
EXPOSE 80

# Chạy SSH và Wetty
CMD service ssh start && wetty --port 80 --ssh-host 127.0.0.1
