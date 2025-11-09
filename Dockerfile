# Dockerfile - Ubuntu 22.04 + code-server
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG CODE_SERVER_VERSION=4.20.0

# cài thiết bị cơ bản
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg2 sudo locales unzip git \
    build-essential procps lsb-release \
 && rm -rf /var/lib/apt/lists/*

# tạo user không phải root
ARG USER=ubuntu
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} || true \
 && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER} \
 && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# cài code-server (official binary)
RUN CODE_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz" \
 && mkdir -p /tmp/code-server \
 && curl -fsSL "$CODE_URL" -o /tmp/code-server/code-server.tgz \
 && tar -xzf /tmp/code-server/code-server.tgz -C /tmp/code-server --strip-components=1 \
 && mv /tmp/code-server/bin/code-server /usr/local/bin/code-server \
 && chmod +x /usr/local/bin/code-server \
 && rm -rf /tmp/code-server

# set locale để terminal hiển thị đúng tiếng
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

WORKDIR /home/${USER}
# mount workspace và config permission
RUN chown -R ${USER}:${USER} /home/${USER}

# port sẽ được Render cung cấp trong PORT env
ENV PORT=8080
EXPOSE 8080

# user mặc định
USER ${USER}

# command: dùng env PASSWORD để auth; nếu muốn không auth set AUTH=none (không khuyến nghị)
# code-server options: --host 0.0.0.0 --port $PORT --auth password
ENTRYPOINT [ "sh", "-c", "\
  if [ -z \"$PASSWORD\" ]; then echo 'WARNING: $PASSWORD not set — using default password: render'; PASSWORD=render; fi; \
  code-server --bind-addr 0.0.0.0:${PORT} --auth password --user-data-dir /home/ubuntu/.local/share/code-server --extensions-dir /home/ubuntu/.local/share/code-server/extensions \
"]
