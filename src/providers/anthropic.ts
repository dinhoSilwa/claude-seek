/**
 * @spec: TASK-023
 * @epic: EPIC-007
 */
import { BaseProvider, ProviderError } from './base.js';
import type { ProviderConfig } from '../types/index.js';
import type { ChatRequest, ChatResponse } from '../types/message.js';
import type { Model } from '../types/model.js';

interface AnthropicContent {
  type: 'text';
  text: string;
}

interface AnthropicResponse {
  id: string;
  model: string;
  content: AnthropicContent[];
  stop_reason: string;
  usage: { input_tokens: number; output_tokens: number };
}

const ANTHROPIC_MODELS: Model[] = [
  {
    id: 'claude-sonnet-4-6',
    name: 'Claude Sonnet 4.6',
    provider: 'anthropic',
    contextWindow: 200000,
    capabilities: ['chat', 'code', 'vision', 'function_calling', 'streaming'],
    isDefault: true,
  },
  {
    id: 'claude-opus-4-8',
    name: 'Claude Opus 4.8',
    provider: 'anthropic',
    contextWindow: 200000,
    capabilities: ['chat', 'code', 'vision', 'function_calling', 'streaming'],
  },
  {
    id: 'claude-haiku-4-5-20251001',
    name: 'Claude Haiku 4.5',
    provider: 'anthropic',
    contextWindow: 200000,
    capabilities: ['chat', 'code', 'streaming'],
  },
];

export class AnthropicProvider extends BaseProvider {
  readonly name = 'Anthropic';
  readonly id = 'anthropic';
  readonly defaultBaseUrl = 'https://api.anthropic.com';

  constructor(config: ProviderConfig) {
    super(config);
  }

  protected buildAnthropicHeaders(): Record<string, string> {
    return {
      'Content-Type': 'application/json',
      'x-api-key': this.apiKey,
      'anthropic-version': '2023-06-01',
    };
  }

  async listModels(): Promise<Model[]> {
    return ANTHROPIC_MODELS;
  }

  async chat(request: ChatRequest): Promise<ChatResponse> {
    const systemMessages = request.messages.filter((m) => m.role === 'system');
    const userMessages = request.messages.filter((m) => m.role !== 'system');

    const body: Record<string, unknown> = {
      model: request.model,
      messages: userMessages,
      max_tokens: request.maxTokens ?? 4096,
    };

    if (systemMessages.length > 0) {
      body['system'] = systemMessages.map((m) => m.content).join('\n');
    }

    const data = await this.fetchJSON<AnthropicResponse>(
      `${this.baseUrl}/v1/messages`,
      {
        method: 'POST',
        headers: this.buildAnthropicHeaders(),
        body: JSON.stringify(body),
      },
    );

    const content = data.content.filter((c) => c.type === 'text').map((c) => c.text).join('');

    return {
      id: data.id,
      model: data.model,
      provider: this.id,
      content,
      usage: {
        promptTokens: data.usage.input_tokens,
        completionTokens: data.usage.output_tokens,
        totalTokens: data.usage.input_tokens + data.usage.output_tokens,
      },
      finishReason: data.stop_reason ?? 'stop',
    };
  }

  async validateApiKey(apiKey: string): Promise<boolean> {
    try {
      const res = await fetch(`${this.defaultBaseUrl}/v1/models`, {
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
      });
      if (res.status === 401) return false;
      if (!res.ok) throw new ProviderError(`HTTP ${res.status}`, res.status, this.id);
      return true;
    } catch {
      return false;
    }
  }
}
