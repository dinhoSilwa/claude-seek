/**
 * @spec: TASK-026
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

const GLM_MODELS: Model[] = [
  {
    id: 'glm-4-plus',
    name: 'GLM-4 Plus',
    provider: 'glm',
    contextWindow: 128000,
    capabilities: ['chat', 'code', 'function_calling', 'streaming'],
    isDefault: true,
  },
  {
    id: 'glm-4-flash',
    name: 'GLM-4 Flash',
    provider: 'glm',
    contextWindow: 128000,
    capabilities: ['chat', 'code', 'streaming'],
  },
  {
    id: 'glm-4v-plus',
    name: 'GLM-4V Plus',
    provider: 'glm',
    contextWindow: 8192,
    capabilities: ['chat', 'vision', 'streaming'],
  },
];

export class GLMProvider extends BaseProvider {
  readonly name = 'GLM (Zhipu AI)';
  readonly id = 'glm';
  readonly defaultBaseUrl = 'https://open.bigmodel.cn/api/paas/v4';

  constructor(config: ProviderConfig) {
    super(config);
  }

  async listModels(): Promise<Model[]> {
    return GLM_MODELS;
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
      const res = await fetch(`${this.defaultBaseUrl}/models`, {
        headers: { Authorization: `Bearer ${apiKey}` },
      });
      return res.ok;
    } catch {
      return false;
    }
  }
}
