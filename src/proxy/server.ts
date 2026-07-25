/**
 * @spec: TASK-039
 * @epic: EPIC-011
 */

import http from 'http';
import https from 'https';
import { URL } from 'url';
import type { ProviderCredential } from '../types/config.js';
import { anthropicToOpenAI, openAIToAnthropic } from './translate.js';
import type { AnthropicRequest } from './translate.js';
import { pipeOpenAIStreamToAnthropic } from './stream.js';

const PROVIDER_BASE_URLS: Record<string, string> = {
  deepseek: 'https://api.deepseek.com/v1',
  openai: 'https://api.openai.com/v1',
  openrouter: 'https://openrouter.ai/api/v1',
  kimi: 'https://api.moonshot.cn/v1',
  glm: 'https://open.bigmodel.cn/api/paas/v4',
};

function readBody(req: http.IncomingMessage): Promise<string> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    req.on('data', (c: Buffer) => chunks.push(c));
    req.on('end', () => resolve(Buffer.concat(chunks).toString()));
    req.on('error', reject);
  });
}

function fetchUpstream(
  baseUrl: string,
  path: string,
  apiKey: string,
  method: string,
  body: string,
  extraHeaders?: Record<string, string>,
): Promise<http.IncomingMessage> {
  return new Promise((resolve, reject) => {
    const target = new URL(path, baseUrl);
    const isHttps = target.protocol === 'https:';
    const lib = isHttps ? https : http;

    const req = lib.request(
      {
        hostname: target.hostname,
        port: target.port || (isHttps ? 443 : 80),
        path: target.pathname + target.search,
        method,
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
          'Content-Length': Buffer.byteLength(body),
          ...extraHeaders,
        },
      },
      resolve,
    );
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

export function createProxyServer(providerId: string, cred: ProviderCredential): http.Server {
  const baseUrl = cred.baseUrl ?? PROVIDER_BASE_URLS[providerId] ?? '';

  const extraHeaders: Record<string, string> =
    providerId === 'openrouter'
      ? { 'HTTP-Referer': 'https://github.com/dinhoSilwa/claude-seek', 'X-Title': 'Orion CLI' }
      : {};

  return http.createServer(async (req, res) => {
    const url = req.url ?? '/';

    // pass-through health check
    if (req.method === 'GET' && url === '/') {
      res.writeHead(200).end('Orion proxy OK');
      return;
    }

    // models endpoint — forward as-is or return empty list
    if (req.method === 'GET' && url.includes('/models')) {
      try {
        const upstream = await fetchUpstream(baseUrl, '/models', cred.apiKey, 'GET', '', extraHeaders);
        res.writeHead(upstream.statusCode ?? 200, { 'Content-Type': 'application/json' });
        upstream.pipe(res);
      } catch {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ data: [] }));
      }
      return;
    }

    // messages endpoint — translate Anthropic → OpenAI
    if (req.method === 'POST' && url.includes('/messages')) {
      const rawBody = await readBody(req);
      let anthropicReq: AnthropicRequest;
      try {
        anthropicReq = JSON.parse(rawBody) as AnthropicRequest;
      } catch {
        res.writeHead(400).end(JSON.stringify({ error: 'Invalid JSON' }));
        return;
      }

      const openAIReq = anthropicToOpenAI(anthropicReq);
      const upstreamBody = JSON.stringify(openAIReq);
      const requestId = Date.now().toString(36);

      try {
        const upstream = await fetchUpstream(
          baseUrl,
          '/chat/completions',
          cred.apiKey,
          'POST',
          upstreamBody,
          extraHeaders,
        );

        if (anthropicReq.stream) {
          res.writeHead(200, {
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            Connection: 'keep-alive',
          });
          await pipeOpenAIStreamToAnthropic(upstream, res, anthropicReq.model, requestId);
        } else {
          const responseBody = await readBody(upstream as unknown as http.IncomingMessage);
          if (!upstream.statusCode || upstream.statusCode >= 400) {
            res.writeHead(upstream.statusCode ?? 500, { 'Content-Type': 'application/json' });
            res.end(responseBody);
            return;
          }
          const openAIRes = JSON.parse(responseBody);
          const anthropicRes = openAIToAnthropic(openAIRes, anthropicReq.model);
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify(anthropicRes));
        }
      } catch (err) {
        res.writeHead(502, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: { type: 'proxy_error', message: (err as Error).message } }));
      }
      return;
    }

    res.writeHead(404).end(JSON.stringify({ error: 'Not found' }));
  });
}

export function startProxy(providerId: string, cred: ProviderCredential): Promise<{ port: number; server: http.Server }> {
  return new Promise((resolve, reject) => {
    const server = createProxyServer(providerId, cred);
    server.listen(0, '127.0.0.1', () => {
      const addr = server.address();
      if (!addr || typeof addr === 'string') { reject(new Error('Failed to bind proxy')); return; }
      resolve({ port: addr.port, server });
    });
    server.on('error', reject);
  });
}
