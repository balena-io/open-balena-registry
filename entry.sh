#!/bin/sh

echo "${TOKEN_AUTH_ROOTCERTBUNDLE}" | base64 --decode >"${CERT_FILE}"

# Prepare the registry JWKS file
jwks_cert_file="/certs/private/${REGISTRY2_TOKEN_AUTH_ISSUER}.jwks.json"
registry_jwks_file="/tmp/registry-jwks.json"
if [ -f "${jwks_cert_file}" ]; then
    ln -s "${jwks_cert_file}" "${registry_jwks_file}"
elif [ -n "${API_TOKENAUTH_JWKS}" ]; then
    echo "${API_TOKENAUTH_JWKS}" | base64 --decode >"${registry_jwks_file}"
fi

# Ensure the registry JWKS file exists and is valid JSON
if ! jq -e . "${registry_jwks_file}" > /dev/null 2>&1; then
    echo "Error: Registry JWKS file not found or is invalid." >&2
    exit 1
fi

exec /usr/local/bin/docker-registry serve /etc/docker-registry.yml
