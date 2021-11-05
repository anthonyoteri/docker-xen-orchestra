#!/bin/bash

cat /tmp/config.toml | envsubst > /config/config.toml

exec "$@"