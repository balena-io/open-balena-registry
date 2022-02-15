#!/bin/bash

# Run confd --onetime
confd -onetime -confdir /usr/src/app/config/confd -backend env

# Source env file
set -a
. /usr/src/app/config/env
set +a

echo "${TOKEN_AUTH_ROOTCERTBUNDLE}" | base64 --decode >"${CERT_FILE}"

exec /usr/local/bin/docker-registry serve /etc/docker-registry.yml
