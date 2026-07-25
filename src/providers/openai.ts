/**
 * @spec: TASK-022
 * @epic: EPIC-007
 */
import { BaseProvider } from './base.js';
import type { ProviderConfig } from '../types/index.js';
import type { ChatRequest, ChatResponse } from '../types/message.js';
import type { Model } from '../types/model.js';

interface OAIModelEntry {
  id: string;
}

interface OAIModelList {
  data: OAIModelEntry[];
}

interface OAIChoice {
  message: { role: string; content: string };
  finish_reason: string;
}

interface OAIChatResponse {
  id: string;
  model: string;
  choices: OAIChoice[];
  usage: { prompt_tokens: number; completion_tokens: number; total_tokens: number };
}

const OPENAI_STATIC_MODELS: Model[] = [
  {
    id: 'gpt-4o',
    name: 'GPT-4o',
    provider: 'openai',
    contextWindow: 128000,
    capabilities: ['chat', 'code', 'vision', 'function_calling', 'streaming'],
    pricing: { inputPer1M: 2.50, outputPer1M: 10.00, currency: 'USD' },
    isDefault: true,
  },
  {
    id: 'gpt-4o-mini',
    name: 'GPT-4o Mini',
    provider: 'openai',
    contextWindow: 128000,
    capabilities: ['chat', 'code', 'vision', 'function_calling', 'streaming'],
    pricing: { inputPer1M: 0.15, outputPer1M: 0.60, currency: 'USD' },
  },
  {
    id: 'o3',
    name: 'o3',
    provider: 'openai',
    contextWindow: 200000,
    capabilities: ['chat', 'code', 'streaming'],
  },
  {
    id: 'o4-mini',
    name: 'o4-mini',
    provider: 'openai',
    contextWindow: 200000,
    capabilities: ['chat', 'code', 'streaming'],
  },
];

export class OpenAIProvider extends BaseProvider {
  readonly name = 'OpenAI';
  readonly id = 'openai';
  readonly defaultBaseUrl = 'https://api.openai.com/v1';

  constructor(config: ProviderConfig) {
    super(config);
  }

  async listModels(): Promise<Model[]> {
    try {
      const data = await this.fetchJSON<OAIModelList>(`${this.baseUrl}/models`, {
        headers: this.buildHeaders(),
      });
      return data.data
        .filter((m) => m.id.startsWith('gpt-') || m.id.startsWith('o'))
        .map((m) => ({
          id: m.id,
          name: m.id,
          provider: this.id,
          contextWindow: 128000,
          capabilities: ['chat', 'code', 'streaming'] as Model['capabilities'],
        }));
    } catch {
      return OPENAI_STATIC_MODELS;
    }
  }

  async chat(request: ChatRequest): Promise<ChatResponse> {
    const body = {
      model: request.model,
      messages: request.messages,
      max_completion_tokens: request.maxTokens ?? 4096,
      temperature: request.temperature ?? 0.7,
      stream: false,
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
      await this.fetchJSON(`${this.baseUrl}/models`, {
        headers: { Authorization: `Bearer ${apiKey}`, 'Content-Type': 'application/json' },
      });
      return true;
    } catch {
      return false;
    }
  }
}
