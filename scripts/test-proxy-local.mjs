/**
 * Full local proxy test — no real API key needed.
 *
 * Starts a mock upstream + the proxy, then runs:
 *   1. non-streaming request → verify content arrives
 *   2. streaming request     → verify SSE events arrive with content
 *
 * Usage: node scripts/test-proxy-local.mjs
 */
import http from 'http';
import { createProxyServer } from '../dist/proxy/server.js';

// ── helpers ───────────────────────────────────────────────────────────────────

function post(port, path, body) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const req = http.request(
      { hostname: '127.0.0.1', port, path, method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-api-key': 'test', 'Content-Length': Buffer.byteLength(data) } },
      (res) => {
        const chunks = [];
        res.on('data', (c) => chunks.push(c));
        res.on('end', () => resolve({ status: res.statusCode, body: Buffer.concat(chunks).toString() }));
      },
    );
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function postStream(port, path, body) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const req = http.request(
      { hostname: '127.0.0.1', port, path, method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-api-key': 'test', 'Content-Length': Buffer.byteLength(data) } },
      (res) => {
        const events = [];
        let buf = '';
        res.on('data', (chunk) => {
          buf += chunk.toString();
          const lines = buf.split('\n');
          buf = lines.pop() ?? '';
          for (const line of lines) {
            if (line.startsWith('data: ')) {
              try { events.push(JSON.parse(line.slice(6))); } catch {}
            }
          }
        });
        res.on('end', () => resolve({ status: res.statusCode, events }));
      },
    );
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function startMockUpstream(port) {
  return new Promise((resolve) => {
    const s = http.createServer((req, res) => {
      const chunks = [];
      req.on('data', (c) => chunks.push(c));
      req.on('end', () => {
        let parsed = {};
        try { parsed = JSON.parse(Buffer.concat(chunks).toString()); } catch {}
        const replyText = 'olá, tudo bem?';

        if (parsed?.stream) {
          res.writeHead(200, { 'Content-Type': 'text/event-stream' });
          const words = replyText.split(' ');
          words.forEach((word, i) => {
            const chunk = { id: 'mock', model: parsed.model, choices: [{ delta: { content: (i ? ' ' : '') + word }, finish_reason: null }] };
            res.write(`data: ${JSON.stringify(chunk)}\n\n`);
          });
          const final = { id: 'mock', model: parsed.model, choices: [{ delta: {}, finish_reason: 'stop' }], usage: { prompt_tokens: 5, completion_tokens: 3, total_tokens: 8 } };
          res.write(`data: ${JSON.stringify(final)}\n\n`);
          res.write('data: [DONE]\n\n');
          res.end();
        } else {
          const body = { id: 'mock', model: parsed.model, choices: [{ message: { role: 'assistant', content: replyText }, finish_reason: 'stop' }], usage: { prompt_tokens: 5, completion_tokens: 3, total_tokens: 8 } };
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(body));
        }
      });
    });
    s.listen(port, '127.0.0.1', () => resolve(s));
  });
}

// ── run tests ────────────────────────────────────────────────────────────────

let passed = 0;
let failed = 0;

function ok(label, condition, detail = '') {
  if (condition) {
    console.log(`  ✓ ${label}`);
    passed++;
  } else {
    console.log(`  ✗ ${label}${detail ? ': ' + detail : ''}`);
    failed++;
  }
}

const MOCK_PORT = 5001;
const PROXY_PORT = 5002;

console.log('Starting mock upstream...');
const mockServer = await startMockUpstream(MOCK_PORT);

console.log('Starting proxy...');
const proxy = createProxyServer('test', { apiKey: 'fake-key', enabled: true, baseUrl: `http://127.0.0.1:${MOCK_PORT}` });
await new Promise((r) => proxy.listen(PROXY_PORT, '127.0.0.1', r));
console.log(`Proxy on :${PROXY_PORT} → mock on :${MOCK_PORT}\n`);

// ── TEST 1: non-streaming ────────────────────────────────────────────────────
console.log('TEST 1: non-streaming');
const r1 = await post(PROXY_PORT, '/v1/messages', {
  model: 'moonshot-v1-128k',
  max_tokens: 50,
  messages: [{ role: 'user', content: 'oi' }],
  stream: false,
});
const j1 = JSON.parse(r1.body);
ok('status 200', r1.status === 200, `got ${r1.status}`);
ok('type=message', j1.type === 'message', j1.type);
ok('role=assistant', j1.role === 'assistant', j1.role);
ok('content has text', j1.content?.[0]?.text?.length > 0, j1.content?.[0]?.text);
ok('stop_reason=end_turn', j1.stop_reason === 'end_turn', j1.stop_reason);
ok('usage.input_tokens', j1.usage?.input_tokens > 0);
ok('usage.output_tokens', j1.usage?.output_tokens > 0);

// ── TEST 2: streaming ────────────────────────────────────────────────────────
console.log('\nTEST 2: streaming');
const r2 = await postStream(PROXY_PORT, '/v1/messages', {
  model: 'moonshot-v1-128k',
  max_tokens: 50,
  messages: [{ role: 'user', content: 'oi' }],
  stream: true,
});
const types = r2.events.map((e) => e.type);
ok('status 200', r2.status === 200, `got ${r2.status}`);
ok('has message_start', types.includes('message_start'), types.join(','));
ok('has content_block_start', types.includes('content_block_start'), types.join(','));
ok('has content_block_delta', types.includes('content_block_delta'), types.join(','));
ok('has content_block_stop', types.includes('content_block_stop'), types.join(','));
ok('has message_delta', types.includes('message_delta'), types.join(','));
ok('has message_stop', types.includes('message_stop'), types.join(','));

const deltas = r2.events.filter((e) => e.type === 'content_block_delta');
const fullText = deltas.map((e) => e.delta?.text ?? '').join('');
ok('streaming text non-empty', fullText.length > 0, `got: "${fullText}"`);

const msgDelta = r2.events.find((e) => e.type === 'message_delta');
ok('stop_reason=end_turn', msgDelta?.delta?.stop_reason === 'end_turn', msgDelta?.delta?.stop_reason);

// ── summary ──────────────────────────────────────────────────────────────────
console.log(`\n${'─'.repeat(40)}`);
console.log(`${passed + failed} tests: ${passed} passed, ${failed} failed`);

proxy.close();
mockServer.close();
process.exit(failed > 0 ? 1 : 0);
