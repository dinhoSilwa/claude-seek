import { createProxyServer } from '../dist/proxy/server.js';
import { readConfig } from '../dist/config/store.js';

const config = readConfig();
const providerId = process.argv[2] ?? 'kimi';
const cred = config.providers[providerId];

if (!cred) {
  console.error(`Provider '${providerId}' not configured. Run: orion providers add ${providerId}`);
  process.exit(1);
}

process.env.ORION_DEBUG = '1';
const server = createProxyServer(providerId, cred);
server.listen(4000, '127.0.0.1', () => {
  console.log(`Proxy up: http://127.0.0.1:4000  (provider: ${providerId})`);
  console.log('Test:');
  console.log(`  curl -s -X POST http://127.0.0.1:4000/v1/messages \\`);
  console.log(`    -H "Content-Type: application/json" \\`);
  console.log(`    -H "x-api-key: orion-proxy" \\`);
  console.log(`    -d '{"model":"moonshot-v1-128k","max_tokens":50,"messages":[{"role":"user","content":"oi"}],"stream":false}'`);
  console.log('\nCtrl+C to stop.');
});
