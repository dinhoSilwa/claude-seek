/**
 * @spec: TASK-024
 * @epic: EPIC-007
 */
import { BaseProvider } from './base.js';
import type { ProviderConfig } from '../types/index.js';
import type { ChatRequest, ChatResponse } from '../types/message.js';
import type { Model } from '../types/model.js';

interface ORModelEntry {
  id: string;
  name: string;
  context_length: number;
  pricing?: { prompt: string; completion: string };
}

interface ORModelList {
  data: ORModelEntry[];
}

interface ORChoice {
  message: { role: string; content: string };
  finish_reason: string;
}

interface ORChatResponse {
  id: string;
  model: string;
  choices: ORChoice[];
  usage: { prompt_tokens: number; completion_tokens: number; total_tokens: number };
}

export class OpenRouterProvider extends BaseProvider {
  readonly name = 'OpenRouter';
  readonly id = 'openrouter';
  readonly defaultBaseUrl = 'https://openrouter.ai/api/v1';

  constructor(config: ProviderConfig) {
    super(config);
  }

  protected buildHeaders(extra?: Record<string, string>): Record<string, string> {
    return {
      ...super.buildHeaders(extra),
      'HTTP-Referer': 'https://github.com/dinhoSilwa/claude-seek',
      'X-Title': 'Orion CLI',
    };
  }

  async listModels(): Promise<Model[]> {
    const data = await this.fetchJSON<ORModelList>(`${this.baseUrl}/models`, {
      headers: this.buildHeaders(),
    });
    return data.data.map((m) => ({
      id: m.id,
      name: m.name,
      provider: this.id,
      contextWindow: m.context_length ?? 4096,
      capabilities: ['chat', 'streaming'] as Model['capabilities'],
      pricing: m.pricing
        ? {
            inputPer1M: parseFloat(m.pricing.prompt) * 1_000_000,
            outputPer1M: parseFloat(m.pricing.completion) * 1_000_000,
            currency: 'USD' as const,
          }
        : undefined,
    }));
  }

  async chat(request: ChatRequest): Promise<ChatResponse> {
    const body = {
      model: request.model,
      messages: request.messages,
      max_tokens: request.maxTokens ?? 4096,
      temperature: request.temperature ?? 0.7,
    };

    const data = await this.fetchJSON<ORChatResponse>(
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
      const res = await fetch(`${this.defaultBaseUrl}/auth/key`, {
        headers: { Authorization: `Bearer ${apiKey}` },
      });
      return res.ok;
    } catch {
      return false;
    }
  }
}
