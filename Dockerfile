# Base Ubuntu 22.04 + Node.js
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=8080

# 1️⃣ Cài Node.js (v18 LTS)
RUN apt-get update && apt-get install -y curl \
 && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get install -y nodejs \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2️⃣ Copy code
WORKDIR /app
COPY server.js /app/server.js
COPY public /app/public
COPY package.json /app/package.json

# 3️⃣ Cài thư viện cần thiết (express)
RUN npm install

# 4️⃣ Expose port để Render truy cập
EXPOSE 8080

# 5️⃣ Chạy app
CMD ["node", "server.js"]
