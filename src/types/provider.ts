import type { ChatRequest, ChatResponse } from './message.js';
import type { Model } from './model.js';

export interface ProviderConfig {
  apiKey: string;
  baseUrl?: string;
  defaultModel?: string;
  timeout?: number;
}

export interface Provider {
  readonly name: string;
  readonly id: string;

  isConfigured(): boolean;
  listModels(): Promise<Model[]>;
  chat(request: ChatRequest): Promise<ChatResponse>;
  validateApiKey(apiKey: string): Promise<boolean>;
}
