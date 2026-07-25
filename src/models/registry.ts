/**
 * @spec: TASK-027
 * @epic: EPIC-008
 */
import type { Model, ModelCapability } from '../types/index.js';
import type { Provider } from '../types/provider.js';

export class ModelRegistry {
  private cache = new Map<string, Model[]>();

  async loadProvider(provider: Provider): Promise<void> {
    const models = await provider.listModels();
    this.cache.set(provider.id, models);
  }

  async loadAll(providers: Provider[]): Promise<void> {
    await Promise.allSettled(providers.map((p) => this.loadProvider(p)));
  }

  all(): Model[] {
    return [...this.cache.values()].flat();
  }

  byProvider(providerId: string): Model[] {
    return this.cache.get(providerId) ?? [];
  }

  byCapability(capability: ModelCapability): Model[] {
    return this.all().filter((m) => m.capabilities.includes(capability));
  }

  defaultForProvider(providerId: string): Model | undefined {
    const models = this.byProvider(providerId);
    return models.find((m) => m.isDefault) ?? models[0];
  }

  find(providerId: string, modelId: string): Model | undefined {
    return this.byProvider(providerId).find((m) => m.id === modelId);
  }
}
