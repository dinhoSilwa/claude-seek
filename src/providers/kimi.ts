/**
 * @spec: TASK-025
 * @epic: EPIC-007
 */
import { BaseProvider } from './base.js';
import type { ProviderConfig } from '../types/index.js';
import type { ChatRequest, ChatResponse } from '../types/message.js';
import type { Model } from '../types/model.js';

interface OAIChatResponse {
  id: string;
  model: string;
  choices: Array<{ message: { role: string; content: string }; finish_reason: string }>;
  usage: { prompt_tokens: number; completion_tokens: number; total_tokens: number };
}

const KIMI_MODELS: Model[] = [
  {
    id: 'moonshot-v1-128k',
    name: 'Kimi (128k)',
    provider: 'kimi',
    contextWindow: 131072,
    capabilities: ['chat', 'code', 'streaming'],
    isDefault: true,
  },
  {
    id: 'moonshot-v1-32k',
    name: 'Kimi (32k)',
    provider: 'kimi',
    contextWindow: 32768,
    capabilities: ['chat', 'code', 'streaming'],
  },
  {
    id: 'moonshot-v1-8k',
    name: 'Kimi (8k)',
    provider: 'kimi',
    contextWindow: 8192,
    capabilities: ['chat', 'streaming'],
  },
];

export class KimiProvider extends BaseProvider {
  readonly name = 'Kimi (Moonshot)';
  readonly id = 'kimi';
  readonly defaultBaseUrl = 'https://api.moonshot.cn/v1';

  constructor(config: ProviderConfig) {
    super(config);
  }

  async listModels(): Promise<Model[]> {
    return KIMI_MODELS;
  }

  async chat(request: ChatRequest): Promise<ChatResponse> {
    const body = {
      model: request.model,
      messages: request.messages,
      max_tokens: request.maxTokens ?? 4096,
      temperature: request.temperature ?? 0.7,
    };

    const data = await this.fetchJSON<OAIChatResponse>(
      `${this.baseUrl}/chat/completions`,
      {
        method: 'POST',
        headers: this.buildHeaders(),
        body: JSON.stringify(body),
      },
    );

    return {
      id: data.id,
      model: data.model,
      provider: this.id,
      content: data.choices[0]?.message.content ?? '',
      usage: {
        promptTokens: data.usage.prompt_tokens,
        completionTokens: data.usage.completion_tokens,
        totalTokens: data.usage.total_tokens,
      },
      finishReason: data.choices[0]?.finish_reason ?? 'stop',
    };
  }

  async validateApiKey(apiKey: string): Promise<boolean> {
    try {
      await this.fetchJSON(`${this.defaultBaseUrl}/models`, {
        headers: { Authorization: `Bearer ${apiKey}`, 'Content-Type': 'application/json' },
      });
      return true;
    } catch {
      return false;
    }
  }
}
