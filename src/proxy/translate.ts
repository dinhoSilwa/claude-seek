/**
 * @spec: TASK-037
 * @epic: EPIC-011
 */

// ── Anthropic types ──────────────────────────────────────────────────────────

export interface AnthropicContentBlock {
  type: 'text' | 'image' | 'tool_use' | 'tool_result';
  text?: string;
}

export interface AnthropicMessage {
  role: 'user' | 'assistant';
  content: string | AnthropicContentBlock[];
}

export interface AnthropicRequest {
  model: string;
  max_tokens: number;
  messages: AnthropicMessage[];
  system?: string;
  stream?: boolean;
  temperature?: number;
  top_p?: number;
  stop_sequences?: string[];
}

export interface AnthropicResponse {
  id: string;
  type: 'message';
  role: 'assistant';
  model: string;
  content: AnthropicContentBlock[];
  stop_reason: 'end_turn' | 'max_tokens' | 'stop_sequence' | null;
  stop_sequence: string | null;
  usage: { input_tokens: number; output_tokens: number };
}

// ── OpenAI types ─────────────────────────────────────────────────────────────

export interface OpenAIMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface OpenAIRequest {
  model: string;
  messages: OpenAIMessage[];
  max_tokens?: number;
  stream?: boolean;
  temperature?: number;
  top_p?: number;
  stop?: string[];
}

export interface OpenAIResponse {
  id: string;
  model: string;
  choices: Array<{
    message: { role: string; content: string };
    finish_reason: string;
  }>;
  usage: { prompt_tokens: number; completion_tokens: number; total_tokens: number };
}

// ── Translators ───────────────────────────────────────────────────────────────

export function contentToString(content: string | AnthropicContentBlock[]): string {
  if (typeof content === 'string') return content;
  return content
    .filter((b) => b.type === 'text' && b.text)
    .map((b) => b.text!)
    .join('');
}

export function anthropicToOpenAI(req: AnthropicRequest): OpenAIRequest {
  const messages: OpenAIMessage[] = [];

  if (req.system) {
    messages.push({ role: 'system', content: req.system });
  }

  for (const msg of req.messages) {
    messages.push({ role: msg.role, content: contentToString(msg.content) });
  }

  return {
    model: req.model,
    messages,
    max_tokens: req.max_tokens,
    stream: req.stream,
    temperature: req.temperature,
    top_p: req.top_p,
    stop: req.stop_sequences,
  };
}

export function openAIToAnthropic(res: OpenAIResponse, model: string): AnthropicResponse {
  const choice = res.choices[0];
  const text = choice?.message?.content ?? '';
  const finishReason = choice?.finish_reason ?? 'end_turn';

  const stopReasonMap: Record<string, AnthropicResponse['stop_reason']> = {
    stop: 'end_turn',
    length: 'max_tokens',
    content_filter: 'end_turn',
  };

  return {
    id: `msg_${res.id}`,
    type: 'message',
    role: 'assistant',
    model,
    content: [{ type: 'text', text }],
    stop_reason: stopReasonMap[finishReason] ?? 'end_turn',
    stop_sequence: null,
    usage: {
      input_tokens: res.usage?.prompt_tokens ?? 0,
      output_tokens: res.usage?.completion_tokens ?? 0,
    },
  };
}
