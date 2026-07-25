import type { Provider, ProviderConfig } from '../types/index.js';
import type { ChatRequest, ChatResponse } from '../types/message.js';
import type { Model } from '../types/model.js';

export abstract class BaseProvider implements Provider {
  abstract readonly name: string;
  abstract readonly id: string;
  abstract readonly defaultBaseUrl: string;

  protected config: ProviderConfig;

  constructor(config: ProviderConfig) {
    this.config = config;
  }

  isConfigured(): boolean {
    return Boolean(this.config.apiKey?.trim());
  }

  protected get baseUrl(): string {
    return this.config.baseUrl ?? this.defaultBaseUrl;
  }

  protected get apiKey(): string {
    return this.config.apiKey;
  }

  protected get timeout(): number {
    return this.config.timeout ?? 30_000;
  }

  abstract listModels(): Promise<Model[]>;
  abstract chat(request: ChatRequest): Promise<ChatResponse>;
  abstract validateApiKey(apiKey: string): Promise<boolean>;

  protected buildHeaders(extra?: Record<string, string>): Record<string, string> {
    return {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${this.apiKey}`,
      ...extra,
    };
  }

  protected async fetchJSON<T>(
    url: string,
    options: RequestInit = {},
  ): Promise<T> {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), this.timeout);

    try {
      const res = await fetch(url, {
        ...options,
        signal: controller.signal,
      });

      if (!res.ok) {
        const body = await res.text().catch(() => '');
        throw new ProviderError(
          `HTTP ${res.status} from ${this.name}: ${body}`,
          res.status,
          this.id,
        );
      }

      return res.json() as Promise<T>;
    } finally {
      clearTimeout(timer);
    }
  }
}

export class ProviderError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number,
    public readonly providerId: string,
  ) {
    super(message);
    this.name = 'ProviderError';
  }
}
