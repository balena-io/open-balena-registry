#!/bin/sh

echo "${TOKEN_AUTH_ROOTCERTBUNDLE}" | base64 --decode >"${CERT_FILE}"

exec /usr/local/bin/docker-registry serve /etc/docker-registry.yml
