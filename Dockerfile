FROM node:bullseye-slim as build

# Install basic system requirements
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    git \
    gettext \
    python3 \
    libvhdi-utils \
    lvm2 \
    ca-certificates \
    cifs-utils && \
  rm -rf /var/lib/apt/lists/*

# Install Xen Orchestra from sources
RUN git clone -b master https://github.com/vatesfr/xen-orchestra && \
    cd xen-orchestra && \
    yarn && \
    yarn build && \
    yarn cache clean

# Install plugins
RUN cd xen-orchestra/packages/xo-server/node_modules && \
    find ../.. \
        -maxdepth 1 \
        -mindepth 1 \
        -not -name 'xo-server' \
        -not -name 'xo-web' \
        -not -name 'xo-server-cloud' \
        -exec ln -s {} . \;

FROM node:bullseye-slim

RUN apt-get update && apt-get install -y \
    libvhdi-utils \
    lvm2 \
    gettext \
    nfs-common \
    cifs-utils \
    ca-certificates \
    curl \
  && rm -rf /var/lib/apt/lists/*

RUN ln -sf /config /etc/xo-server

COPY --from=build ./xen-orchestra /app
COPY config.toml /tmp
COPY entrypoint.sh /usr/local/bin/

VOLUME /config
EXPOSE 443
WORKDIR /app/packages/xo-server

ENV REDIS_URI redis://localhost:6379/0
ENTRYPOINT ["entrypoint.sh"]
CMD ["yarn", "start"]
