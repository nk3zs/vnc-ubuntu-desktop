FROM dorowu/ubuntu-desktop-lxde-vnc:focal

LABEL maintainer="ChatGPT Ubuntu Web Desktop"

# Xoá repo lỗi (Chrome)
RUN rm -f /etc/apt/sources.list.d/google-chrome.list || true

# Expose web noVNC
EXPOSE 6080
ENV PORT=6080

# CMD khởi động noVNC + VNC server (có sẵn trong image dorowu)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
