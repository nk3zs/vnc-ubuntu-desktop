# Dockerfile chuẩn cho Wetty + ssh server trên Ubuntu

FROM ubuntu:22.04

# Cập nhật & cài ssh + curl + nodejs (dùng nodejs để chạy wetty)
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Cài Wetty
RUN npm install -g wetty

# Tạo thư mục chứa sshd
RUN mkdir /var/run/sshd

# Cho phép đăng nhập ssh root (dùng password 'root')
RUN echo 'root:root' | chpasswd

# Cho phép root login qua ssh password
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Tắt việc yêu cầu tty cho ssh
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Expose port 3000 cho wetty
EXPOSE 3000

# Khởi động sshd rồi chạy wetty trên port 3000
CMD service ssh start && wetty --port 3000 --ssh-host 127.0.0.1
