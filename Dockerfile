# Dockerfile - Ubuntu 22.04 + Node.js + code-server
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG CODE_SERVER_VERSION=4.20.0

# 1. Cài các gói cơ bản
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg2 sudo locales unzip git build-essential procps lsb-release \
 && rm -rf /var/lib/apt/lists/*

# 2. Cài Node.js LTS (bắt buộc để chạy code-server)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
 && apt-get install -y nodejs \
 && node -v && npm -v

# 3. Tạo user "ubuntu"
ARG USER=ubuntu
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} || true \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
 && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 4. Cài code-server (bản chính thức)
RUN CODE_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz" \
 && mkdir -p /tmp/code-server \
 && curl -fsSL "$CODE_URL" -o /tmp/code-server/code-server.tgz \
 && tar -xzf /tmp/code-server/code-server.tgz -C /tmp/code-server --strip-components=1 \
 && mv /tmp/code-server/bin/code-server /usr/local/bin/code-server \
 && chmod +x /usr/local/bin/code-server \
 && rm -rf /tmp/code-server

# 5. Locale cho terminal
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

WORKDIR /home/${USER}
RUN chown -R ${USER}:${USER} /home/${USER}

ENV PORT=8080
EXPOSE 8080
USER ${USER}

# 6. Chạy code-server
ENTRYPOINT [ "sh", "-c", "\
  if [ -z \"$PASSWORD\" ]; then echo 'WARNING: \$PASSWORD not set — using default password: render'; PASSWORD=render; fi; \
  code-server --bind-addr 0.0.0.0:${PORT} --auth password --user-data-dir /home/ubuntu/.local/share/code-server --extensions-dir /home/ubuntu/.local/share/code-server/extensions \
"]
