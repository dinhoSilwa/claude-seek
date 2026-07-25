/**
 * @spec: TASK-021
 * @epic: EPIC-007
 */
import { BaseProvider } from './base.js';
import type { ProviderConfig } from '../types/index.js';
import type { ChatRequest, ChatResponse } from '../types/message.js';
import type { Model } from '../types/model.js';

interface OpenAIMessage {
  role: string;
  content: string;
}

interface OpenAIChoice {
  message: OpenAIMessage;
  finish_reason: string;
}

interface OpenAIUsage {
  prompt_tokens: number;
  completion_tokens: number;
  total_tokens: number;
}

interface OpenAIChatResponse {
  id: string;
  model: string;
  choices: OpenAIChoice[];
  usage: OpenAIUsage;
}

const DEEPSEEK_MODELS: Model[] = [
  {
    id: 'deepseek-v4-pro',
    name: 'DeepSeek V4 Pro',
    provider: 'deepseek',
    contextWindow: 65536,
    capabilities: ['chat', 'code', 'function_calling', 'streaming'],
    pricing: { inputPer1M: 0.27, outputPer1M: 1.10, currency: 'USD' },
    isDefault: true,
  },
  {
    id: 'deepseek-v4-flash',
    name: 'DeepSeek V4 Flash',
    provider: 'deepseek',
    contextWindow: 65536,
    capabilities: ['chat', 'code', 'streaming'],
    pricing: { inputPer1M: 0.07, outputPer1M: 0.28, currency: 'USD' },
  },
  {
    id: 'deepseek-r2',
    name: 'DeepSeek R2 (Reasoner)',
    provider: 'deepseek',
    contextWindow: 65536,
    capabilities: ['chat', 'code', 'streaming'],
  },
];

export class DeepSeekProvider extends BaseProvider {
  readonly name = 'DeepSeek';
  readonly id = 'deepseek';
  readonly defaultBaseUrl = 'https://api.deepseek.com/v1';

  constructor(config: ProviderConfig) {
    super(config);
  }

  async listModels(): Promise<Model[]> {
    return DEEPSEEK_MODELS;
  }

  async chat(request: ChatRequest): Promise<ChatResponse> {
    const body = {
      model: request.model,
      messages: request.messages,
      max_tokens: request.maxTokens ?? 4096,
      temperature: request.temperature ?? 0.7,
      stream: false,
    };

    const data = await this.fetchJSON<OpenAIChatResponse>(
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
