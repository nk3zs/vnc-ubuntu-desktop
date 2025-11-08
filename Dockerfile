FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Ho_Chi_Minh

RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata sudo wget curl gnupg2 software-properties-common \
    tightvncserver novnc websockify ubuntu-desktop-minimal dbus-x11 xterm xfce4 xfce4-goodies && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

USER ubuntu
WORKDIR /home/ubuntu

RUN mkdir -p ~/.vnc && \
    echo "ubuntu" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# ✅ Sửa lỗi ở đây
RUN echo '#!/bin/bash\n\
vncserver -kill :1 || true\n\
vncserver :1 -geometry 1366x768 -depth 24\n\
sleep 2\n\
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &\n\
echo "✅ Ubuntu Desktop is running at :6080"\n\
tail -f /dev/null\n' > ~/start.sh && chmod +x ~/start.sh

USER root
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

EXPOSE 6080
CMD ["/home/ubuntu/start.sh"]
