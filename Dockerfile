FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài các gói cơ bản
RUN apt update && apt install -y \
    sudo nano curl wget systemd systemctl iproute2 net-tools \
    openssh-server && \
    apt clean

# Tạo user
RUN useradd -m ubuntu && echo "ubuntu:123456" | chpasswd && adduser ubuntu sudo

# SSH config
RUN mkdir /var/run/sshd

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]
