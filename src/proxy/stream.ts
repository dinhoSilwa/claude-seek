/**
 * @spec: TASK-038
 * @epic: EPIC-011
 *
 * Translates OpenAI SSE stream → Anthropic SSE stream.
 *
 * OpenAI chunk:  data: {"choices":[{"delta":{"content":"hi"},"finish_reason":null}]}
 * Anthropic emits: message_start → content_block_start → content_block_delta* → content_block_stop → message_delta → message_stop
 */

import type { IncomingMessage } from 'http';
import type { ServerResponse } from 'http';

function sseEvent(res: ServerResponse, event: string, data: unknown): void {
  res.write(`event: ${event}\ndata: ${JSON.stringify(data)}\n\n`);
}

interface OpenAIDelta {
  choices: Array<{ delta: { content?: string; role?: string }; finish_reason: string | null }>;
  id?: string;
  model?: string;
  usage?: { prompt_tokens: number; completion_tokens: number; total_tokens: number };
}

export async function pipeOpenAIStreamToAnthropic(
  upstreamRes: IncomingMessage,
  clientRes: ServerResponse,
  model: string,
  requestId: string,
): Promise<void> {
  const msgId = `msg_${requestId}`;
  let outputTokens = 0;
  let inputTokens = 0;
  let headersSent = false;

  return new Promise((resolve, reject) => {
    let buffer = '';

    upstreamRes.on('data', (chunk: Buffer) => {
      buffer += chunk.toString();
      const lines = buffer.split('\n');
      buffer = lines.pop() ?? '';

      for (const line of lines) {
        if (!line.startsWith('data: ')) continue;
        const payload = line.slice(6).trim();
        if (payload === '[DONE]') continue;

        let parsed: OpenAIDelta;
        try { parsed = JSON.parse(payload); } catch { continue; }

        if (!headersSent) {
          headersSent = true;
          sseEvent(clientRes, 'message_start', {
            type: 'message_start',
            message: {
              id: msgId,
              type: 'message',
              role: 'assistant',
              model,
              content: [],
              stop_reason: null,
              stop_sequence: null,
              usage: { input_tokens: 0, output_tokens: 0 },
            },
          });
          sseEvent(clientRes, 'content_block_start', {
            type: 'content_block_start',
            index: 0,
            content_block: { type: 'text', text: '' },
          });
          clientRes.write('event: ping\ndata: {"type":"ping"}\n\n');
        }

        const choice = parsed.choices?.[0];
        if (!choice) continue;

        const text = choice.delta?.content;
        if (text) {
          outputTokens += Math.ceil(text.length / 4);
          sseEvent(clientRes, 'content_block_delta', {
            type: 'content_block_delta',
            index: 0,
            delta: { type: 'text_delta', text },
          });
        }

        if (parsed.usage) {
          inputTokens = parsed.usage.prompt_tokens;
          outputTokens = parsed.usage.completion_tokens;
        }

        if (choice.finish_reason) {
          const stopReasonMap: Record<string, string> = {
            stop: 'end_turn',
            length: 'max_tokens',
            content_filter: 'end_turn',
          };
          const stopReason = stopReasonMap[choice.finish_reason] ?? 'end_turn';

          sseEvent(clientRes, 'content_block_stop', { type: 'content_block_stop', index: 0 });
          sseEvent(clientRes, 'message_delta', {
            type: 'message_delta',
            delta: { stop_reason: stopReason, stop_sequence: null },
            usage: { output_tokens: outputTokens },
          });
          sseEvent(clientRes, 'message_stop', { type: 'message_stop' });
        }
      }
    });

    upstreamRes.on('end', () => {
      if (!headersSent) {
        // empty response — send minimal valid stream
        sseEvent(clientRes, 'message_start', {
          type: 'message_start',
          message: { id: msgId, type: 'message', role: 'assistant', model, content: [], stop_reason: null, stop_sequence: null, usage: { input_tokens: inputTokens, output_tokens: 0 } },
        });
        sseEvent(clientRes, 'content_block_start', { type: 'content_block_start', index: 0, content_block: { type: 'text', text: '' } });
        sseEvent(clientRes, 'content_block_stop', { type: 'content_block_stop', index: 0 });
        sseEvent(clientRes, 'message_delta', { type: 'message_delta', delta: { stop_reason: 'end_turn', stop_sequence: null }, usage: { output_tokens: 0 } });
        sseEvent(clientRes, 'message_stop', { type: 'message_stop' });
      }
      clientRes.end();
      resolve();
    });

    upstreamRes.on('error', reject);
  });
}
