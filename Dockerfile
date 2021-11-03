FROM registry.anthonyoteri.com/docker-yarn:slim

# Install basic system requirements
RUN apt-get update && apt-get install -y \
    libpng-dev \
    git \
    python3 \
    libvhdi-utils \
    lvm2 \
    cifs-utils && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app
WORKDIR /app

# Install Xen Orchestra
RUN git clone -b master https://github.com/vatesfr/xen-orchestra . && \
    $HOME/.yarn/bin/yarn && \
    $HOME/.yarn/bin/yarn build

VOLUME /config
EXPOSE 443
COPY root/ /

RUN apt-get update && \
    apt-get install -y gettext && \
    rm -rf /var/lib/apt/lists/*

ENV REDIS_URL redis://localhost:6379/0
COPY entrypoint.sh /entrypoint.sh

WORKDIR /app/packages/xo-server
CMD ["/entrypoint.sh", "yarn", "start"]
