const jose = require('node-jose');
const fs = require('node:fs');

async function main() {
	const issuer = process.env['TOKEN_AUTH_CERT_ISSUER'];
	if (!issuer) {
		throw new Error('TOKEN_AUTH_CERT_ISSUER not set, giving up on JWKS generation');
	}
	const pem = fs.readFileSync(`/certs/private/${issuer}.pem`, 'utf8');
	const kid = fs.readFileSync(`/certs/private/${issuer}.kid`, 'utf8').trim();
	const keystore = jose.JWK.createKeyStore();
	await keystore.add(pem, 'pem', { use: 'sig', alg: 'ES256' });
	const jwks = keystore.toJSON(true);
	if (jwks.keys != null && jwks.keys[0] != null) {
		jwks.keys[0].kid = kid;
	}
	fs.writeFileSync('/etc/jwks', JSON.stringify(jwks, null, 2));
}

main().then(() => {
	console.log('PWKS written to /etc/pwks');
	process.exit(0);
}).catch((err) => {
	console.error('Error writing PWKS:', err);
	process.exit(1);
});
