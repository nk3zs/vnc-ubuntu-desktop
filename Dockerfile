# Ubuntu Desktop nhẹ + VNC + noVNC
FROM dorowu/ubuntu-desktop-lxde-vnc:focal

LABEL maintainer="ChatGPT Ubuntu Desktop Web"

# Xóa repo lỗi Chrome (nếu có)
RUN rm -f /etc/apt/sources.list.d/google-chrome.list || true

# Cập nhật hệ thống và cài thêm vài công cụ nhẹ
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        xterm sudo curl wget git software-properties-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Đặt độ phân giải thấp hơn để giảm lag
ENV DISPLAY_WIDTH=1024
ENV DISPLAY_HEIGHT=640

# Hình nền Ubuntu
RUN mkdir -p /usr/share/backgrounds && \
    wget -O /usr/share/backgrounds/ubuntu.jpg https://wallpapercave.com/wp/wp9254862.jpg && \
    echo '[Desktop Entry]\nType=Application\nExec=pcmanfm --set-wallpaper=/usr/share/backgrounds/ubuntu.jpg\nHidden=false' > /etc/xdg/autostart/set-wallpaper.desktop

# Expose cổng noVNC
EXPOSE 6080 5900
ENV PORT=6080

# Mặc định khởi chạy VNC/noVNC server
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
