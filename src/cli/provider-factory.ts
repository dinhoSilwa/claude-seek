import type { Provider } from '../types/provider.js';
import { getProviderCredential } from '../config/index.js';
import { DeepSeekProvider } from '../providers/deepseek.js';
import { OpenAIProvider } from '../providers/openai.js';
import { AnthropicProvider } from '../providers/anthropic.js';
import { OpenRouterProvider } from '../providers/openrouter.js';
import { KimiProvider } from '../providers/kimi.js';
import { GLMProvider } from '../providers/glm.js';

type ProviderConstructor = new (config: { apiKey: string }) => Provider;

const PROVIDER_MAP: Record<string, ProviderConstructor> = {
  deepseek: DeepSeekProvider,
  openai: OpenAIProvider,
  anthropic: AnthropicProvider,
  openrouter: OpenRouterProvider,
  kimi: KimiProvider,
  glm: GLMProvider,
};

export function buildProvider(providerId: string): Provider | null {
  const Ctor = PROVIDER_MAP[providerId];
  if (!Ctor) return null;
  const cred = getProviderCredential(providerId);
  if (!cred?.apiKey) return null;
  return new Ctor({ apiKey: cred.apiKey });
}

export function buildAllConfiguredProviders(): Provider[] {
  return Object.keys(PROVIDER_MAP)
    .map((id) => buildProvider(id))
    .filter((p): p is Provider => p !== null && p.isConfigured());
}

export const SUPPORTED_PROVIDERS = Object.keys(PROVIDER_MAP);
