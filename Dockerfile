FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài Ubuntu core + Node.js + các gói cần thiết
RUN apt update && apt install -y \
    curl wget nano sudo iproute2 net-tools openssh-client \
    build-essential python3 python3-pip \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt install -y nodejs \
    && apt clean

# Copy panel vào container
WORKDIR /panel
COPY . .

# Cài package Node.js
RUN npm install

# Render cần PORT, Docker cũng cần port
ENV PORT=10000
EXPOSE 10000

# Chạy panel (spawn bash bên dưới)
CMD ["npm", "start"]
