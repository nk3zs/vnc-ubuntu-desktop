# Ubuntu Desktop (XFCE) + noVNC cho Render
FROM ubuntu:22.04

LABEL maintainer="ChatGPT Ubuntu Desktop Web"

ENV DEBIAN_FRONTEND=noninteractive

# Cập nhật và cài các gói cần thiết
RUN apt-get update && \
    apt-get install -y xfce4 xfce4-goodies tightvncserver novnc websockify sudo wget curl xterm && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Tạo user "ubuntu"
RUN useradd -m -s /bin/bash ubuntu && echo "ubuntu:ubuntu" | chpasswd && adduser ubuntu sudo

USER ubuntu
WORKDIR /home/ubuntu

# Cấu hình VNC
RUN mkdir -p ~/.vnc && \
    echo "ubuntu" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd && \
    echo "#!/bin/bash\n\
xrdb $HOME/.Xresources\n\
startxfce4 &" > ~/.vnc/xstartup && chmod +x ~/.vnc/xstartup

# Script khởi động
RUN echo '#!/bin/bash\n\
vncserver -kill :1 || true\n\
vncserver :1 -geometry 1280x720 -depth 24\n\
websockify --web=/usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5901 &\n\
echo \"VNC started. Access via noVNC on port 6080\"\n\
tail -f /dev/null' > /home/ubuntu/start.sh && chmod +x /home/ubuntu/start.sh

EXPOSE 6080
CMD ["/home/ubuntu/start.sh"]
