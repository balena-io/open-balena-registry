#!/usr/bin/env node
// Prints a JWKS document for the public key of the first certificate in a PEM
// file, using the given key ID (the libtrust KID derived by open-balena-base).
//
// usage: jwks.js <cert.pem> <kid> [alg]
//
// `alg` should match TOKEN_AUTH_JWT_ALGO of open-balena-api, which signs the
// registry tokens. It defaults to RS256 for RSA keys and ES256/ES384/ES512 for
// EC keys on P-256/P-384/P-521.
'use strict'

const crypto = require('node:crypto')
const fs = require('node:fs')

const fail = (message, code = 1) => {
	console.error(message)
	process.exit(code)
}

const [certFile, kid, algOverride] = process.argv.slice(2)
if (!certFile || !kid) {
	fail('usage: jwks.js <cert.pem> <kid> [alg]', 2)
}

// Never load a private key here: exporting one to JWK yields the full CRT
// parameter set (d, p, q, dp, dq, qi), and stripping only 'd' still leaves
// enough to rebuild it. The certificate only ever yields the public key.
const x509 = new crypto.X509Certificate(fs.readFileSync(certFile, 'utf8'))
const jwk = x509.publicKey.export({ format: 'jwk' })

// Allowlist the public fields per key type, rather than deleting private ones
const keyTypes = {
	RSA: {
		fields: ['kty', 'n', 'e'],
		algs: ['RS256', 'RS384', 'RS512', 'PS256', 'PS384', 'PS512'],
		defaultAlg: () => 'RS256',
	},
	EC: {
		fields: ['kty', 'crv', 'x', 'y'],
		algs: ['ES256', 'ES384', 'ES512'],
		defaultAlg: ({ crv }) => ({ 'P-256': 'ES256', 'P-384': 'ES384', 'P-521': 'ES512' })[crv],
	},
}

const keyType = keyTypes[jwk.kty]
if (!keyType) {
	fail(`unsupported key type "${jwk.kty}" in ${certFile}, expected RSA or EC`)
}

const alg = algOverride || keyType.defaultAlg(jwk)
if (!keyType.algs.includes(alg)) {
	fail(`unsupported algorithm "${alg}" for ${jwk.kty} key${jwk.crv ? ` (${jwk.crv})` : ''} in ${certFile}`)
}
// ES256/ES384/ES512 are bound to a single curve each
if (jwk.kty === 'EC' && alg !== keyType.defaultAlg(jwk)) {
	fail(`algorithm "${alg}" does not match curve ${jwk.crv} in ${certFile}`)
}

const key = Object.fromEntries(keyType.fields.map((field) => [field, jwk[field]]))
const x5t = crypto.createHash('sha1').update(x509.raw).digest('base64url')

process.stdout.write(
	JSON.stringify({ keys: [{ ...key, use: 'sig', alg, kid, x5t }] }, null, 2),
)
