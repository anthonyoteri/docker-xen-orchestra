#!/bin/bash

CONFIG=/etc/xo-server/config.toml

cat ${CONFIG}.template | envsubst > $CONFIG

exec "$@"