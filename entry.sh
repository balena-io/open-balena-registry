#!/bin/sh

CERT_B64="$TOKEN_AUTH_ROOTCERTBUNDLE"
CERT_FILE=/certs/registry-tokenauth.crt

mkdir -p $(dirname "$CERT_FILE")
echo "$CERT_B64" | base64 --decode >"$CERT_FILE"

exec /usr/local/bin/docker-registry serve /etc/docker-registry.yml
