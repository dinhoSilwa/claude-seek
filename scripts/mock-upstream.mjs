/**
 * Mock upstream OpenAI-format server.
 * Simulates what Kimi/OpenAI/DeepSeek return so we can test the proxy
 * without real API keys.
 *
 * Usage: node scripts/mock-upstream.mjs [port]
 */
import http from 'http';

const PORT = parseInt(process.argv[2] ?? '5001');

const server = http.createServer((req, res) => {
  const chunks = [];
  req.on('data', (c) => chunks.push(c));
  req.on('end', () => {
    const body = Buffer.concat(chunks).toString();
    let parsed = {};
    try { parsed = JSON.parse(body); } catch {}

    console.log(`[mock] ${req.method} ${req.url}`);
    console.log(`[mock] body: ${body.slice(0, 200)}`);

    // models
    if (req.method === 'GET' && req.url?.includes('/models')) {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ data: [{ id: 'mock-model' }] }));
      return;
    }

    // chat completions
    if (req.method === 'POST' && req.url?.includes('/chat/completions')) {
      const replyText = `Recebi: "${parsed?.messages?.at(-1)?.content ?? '?'}" — resposta do mock upstream.`;

      if (parsed?.stream) {
        // streaming response
        res.writeHead(200, {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
        });

        const words = replyText.split(' ');
        let i = 0;

        const send = () => {
          if (i < words.length) {
            const chunk = {
              id: 'chatcmpl-mock',
              model: parsed.model ?? 'mock-model',
              choices: [{ delta: { content: (i === 0 ? '' : ' ') + words[i] }, finish_reason: null }],
            };
            res.write(`data: ${JSON.stringify(chunk)}\n\n`);
            i++;
            setTimeout(send, 30);
          } else {
            // final chunk with finish_reason + usage
            const final = {
              id: 'chatcmpl-mock',
              model: parsed.model ?? 'mock-model',
              choices: [{ delta: {}, finish_reason: 'stop' }],
              usage: { prompt_tokens: 10, completion_tokens: words.length, total_tokens: 10 + words.length },
            };
            res.write(`data: ${JSON.stringify(final)}\n\n`);
            res.write('data: [DONE]\n\n');
            res.end();
          }
        };
        send();
      } else {
        // non-streaming response
        const response = {
          id: 'chatcmpl-mock',
          model: parsed.model ?? 'mock-model',
          choices: [{ message: { role: 'assistant', content: replyText }, finish_reason: 'stop' }],
          usage: { prompt_tokens: 10, completion_tokens: 20, total_tokens: 30 },
        };
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(response));
      }
      return;
    }

    res.writeHead(404).end(JSON.stringify({ error: 'not found' }));
  });
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Mock upstream running at http://127.0.0.1:${PORT}`);
  console.log('Simulates OpenAI-format API (Kimi/DeepSeek/GLM/etc)\n');
});
