#!/bin/sh

echo "${TOKEN_AUTH_ROOTCERTBUNDLE}" | base64 --decode >"${CERT_FILE}"

# Prepare the registry JWKS file
jwks_cert_file="/certs/private/${REGISTRY2_TOKEN_AUTH_ISSUER}.jwks.json"
registry_jwks_file="/tmp/registry-jwks.json"
if [ -f "${jwks_cert_file}" ]; then
    ln -s "${jwks_cert_file}" "${registry_jwks_file}"
elif [ -n "${API_TOKENAUTH_JWKS}" ]; then
    echo "${API_TOKENAUTH_JWKS}" | base64 --decode >"${registry_jwks_file}"
elif [ -s "${CERT_FILE}" ]; then
    # Generate the JWKS from the API certificate. The key ID is derived by
    # open-balena-base (configure-balena.sh) and exported base64 encoded.
    jwks_kid="$(echo "${REGISTRY_TOKEN_AUTH_CERT_KID:-${TOKEN_AUTH_CERT_KID}}" | base64 --decode)"
    if [ -z "${jwks_kid}" ]; then
        echo "Error: no token auth key ID to generate the registry JWKS with." >&2
        exit 1
    fi
    if ! node /usr/src/app/jwks.js "${CERT_FILE}" "${jwks_kid}" ${TOKEN_AUTH_JWT_ALGO:+"${TOKEN_AUTH_JWT_ALGO}"} >"${registry_jwks_file}"; then
        echo "Error: failed to generate the registry JWKS." >&2
        exit 1
    fi
fi

# Ensure the registry JWKS file exists and is valid JSON
if ! jq -e . "${registry_jwks_file}" > /dev/null 2>&1; then
    echo "Error: Registry JWKS file not found or is invalid." >&2
    exit 1
fi

exec /usr/local/bin/docker-registry serve /etc/docker-registry.yml
