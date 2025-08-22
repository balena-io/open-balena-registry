#!/bin/sh

echo "${TOKEN_AUTH_ROOTCERTBUNDLE}" | base64 --decode >"${CERT_FILE}"
node /usr/src/app/jwks/index.js

exec /usr/local/bin/docker-registry serve /etc/docker-registry.yml
