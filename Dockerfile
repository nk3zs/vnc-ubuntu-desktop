# 🐧 Ubuntu 22.04 + Full Dev Tools + VS Code Web (code-server)
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG CODE_SERVER_VERSION=4.20.0

# 1️⃣ Cài công cụ cơ bản
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg2 sudo locales unzip git build-essential procps lsb-release \
    nano vim htop net-tools iputils-ping software-properties-common \
 && rm -rf /var/lib/apt/lists/*

# 2️⃣ Cài Python + pip
RUN apt-get update && apt-get install -y python3 python3-pip python3-venv && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    pip install --upgrade pip setuptools wheel

# 3️⃣ Cài Node.js (LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# 4️⃣ Tạo user ubuntu
ARG USER=ubuntu
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} || true \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
 && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 5️⃣ Cài code-server (VS Code chạy trong trình duyệt)
RUN CODE_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz" \
 && mkdir -p /tmp/code-server \
 && curl -fsSL "$CODE_URL" -o /tmp/code-server/code-server.tgz \
 && tar -xzf /tmp/code-server/code-server.tgz -C /tmp/code-server --strip-components=1 \
 && mv /tmp/code-server/bin/code-server /usr/local/bin/code-server \
 && chmod +x /usr/local/bin/code-server \
 && rm -rf /tmp/code-server

# 6️⃣ Locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

WORKDIR /home/${USER}
RUN chown -R ${USER}:${USER} /home/${USER}

ENV PORT=8080
EXPOSE 8080
USER ${USER}

# 7️⃣ ENTRYPOINT (ổn định, không lỗi shell)
ENTRYPOINT ["/bin/sh", "-c", "\
if [ -z \"$PASSWORD\" ]; then \
  echo '⚠️  PASSWORD not set — using default: render'; \
  PASSWORD=render; \
fi; \
echo '🔧 Starting Ubuntu Dev Server with code-server...'; \
exec code-server --bind-addr 0.0.0.0:${PORT} --auth password \
  --user-data-dir /home/ubuntu/.local/share/code-server \
  --extensions-dir /home/ubuntu/.local/share/code-server/extensions \
"]
