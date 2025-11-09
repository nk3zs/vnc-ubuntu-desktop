FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=8080

# Cài Node.js + Cockpit
RUN apt-get update && apt-get install -y curl sudo cockpit \
 && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get install -y nodejs && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy mã web
WORKDIR /app
COPY server.js /app/server.js
COPY public /app/public

EXPOSE 8080

# Khởi chạy web login (port 8080)
CMD ["node", "server.js"]
