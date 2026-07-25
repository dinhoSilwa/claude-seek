/**
 * @spec: TASK-030
 * @epic: EPIC-009
 */
import type { Provider } from '../types/provider.js';
import type { ChatRequest, ChatResponse } from '../types/message.js';
import type { OrionConfig } from '../types/config.js';
import { ProviderError } from '../providers/base.js';

export interface RoutingResult {
  response: ChatResponse;
  providerId: string;
  modelId: string;
  fallbackUsed: boolean;
  attemptsCount: number;
}

export class Router {
  constructor(
    private readonly providers: Provider[],
    private readonly config: OrionConfig,
  ) {}

  private orderedProviders(): Provider[] {
    const rules = this.config.routing.rules;
    if (rules.length === 0) return this.providers;

    const withPriority = this.providers.map((p) => {
      const rule = rules.find((r) => r.provider === p.id);
      return { provider: p, priority: rule?.priority ?? 999 };
    });

    return withPriority
      .sort((a, b) => a.priority - b.priority)
      .map((x) => x.provider);
  }

  async route(request: ChatRequest): Promise<RoutingResult> {
    const ordered = this.orderedProviders().filter((p) => p.isConfigured());

    if (ordered.length === 0) {
      throw new Error('No configured providers available.');
    }

    const primary = ordered[0];
    const fallbacks = ordered.slice(1);

    try {
      const response = await primary.chat(request);
      return {
        response,
        providerId: primary.id,
        modelId: request.model,
        fallbackUsed: false,
        attemptsCount: 1,
      };
    } catch (err) {
      if (!this.config.routing.fallback || fallbacks.length === 0) throw err;
      return this.tryFallbacks(request, fallbacks, err as Error);
    }
  }

  private async tryFallbacks(
    request: ChatRequest,
    fallbacks: Provider[],
    lastError: Error,
  ): Promise<RoutingResult> {
    let attempts = 1;
    let error = lastError;

    for (const provider of fallbacks) {
      attempts++;
      try {
        const fallbackModel = this.defaultModelFor(provider, request.model);
        const response = await provider.chat({ ...request, model: fallbackModel });
        return {
          response,
          providerId: provider.id,
          modelId: fallbackModel,
          fallbackUsed: true,
          attemptsCount: attempts,
        };
      } catch (e) {
        error = e as Error;
        if (e instanceof ProviderError && e.statusCode === 401) break;
      }
    }

    throw error;
  }

  private defaultModelFor(provider: Provider, originalModel: string): string {
    const providerDefault = this.config.providers[provider.id]?.defaultModel;
    if (providerDefault) return providerDefault;
    return originalModel;
  }
}
