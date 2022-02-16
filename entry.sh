#!/bin/bash

# Run confd --onetime
confd -onetime -confdir /usr/src/app/config/confd -backend env

# Source env file
set -a
. /usr/src/app/config/env
set +a

# Enable bash job control
set -m

echo "${TOKEN_AUTH_ROOTCERTBUNDLE}" | base64 --decode >"${CERT_FILE}"

/usr/local/bin/docker-registry serve /etc/docker-registry.yml &

# Start redis if env variables match
if [ "$REGISTRY2_CACHE_ENABLED" = "true" ] && [ "$REGISTRY2_CACHE_ADDR" = "127.0.0.1:6379" ]
then
    /usr/bin/redis-server /etc/redis/redis.conf &
fi

fg %1