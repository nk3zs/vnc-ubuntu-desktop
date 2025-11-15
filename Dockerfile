FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài các gói cơ bản
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
    htop \
    ssh-import-id \
    && rm -rf /var/lib/apt/lists/*

# Cài Node.js 18 từ NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# Cài Wetty (web terminal)
RUN npm install -g wetty

# Chuẩn bị SSH
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Mở port 80
EXPOSE 80

# Chạy SSH và Wetty
CMD service ssh start && wetty --port 80 --ssh-host 127.0.0.1
