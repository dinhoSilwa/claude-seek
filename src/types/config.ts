export interface ProviderCredential {
  apiKey: string;
  baseUrl?: string;
  defaultModel?: string;
  enabled: boolean;
}

export interface RoutingRule {
  provider: string;
  priority: number;
  conditions?: {
    capability?: string;
    maxCost?: number;
  };
}

export interface OrionConfig {
  version: string;
  defaultProvider?: string;
  providers: Record<string, ProviderCredential>;
  routing: {
    strategy: 'priority' | 'cost' | 'speed';
    fallback: boolean;
    rules: RoutingRule[];
  };
  history: {
    enabled: boolean;
    maxEntries: number;
  };
  ui: {
    noColor: boolean;
    logLevel: 'debug' | 'info' | 'warn' | 'error';
  };
}

export const DEFAULT_CONFIG: OrionConfig = {
  version: '1',
  providers: {},
  routing: {
    strategy: 'priority',
    fallback: true,
    rules: [],
  },
  history: {
    enabled: true,
    maxEntries: 1000,
  },
  ui: {
    noColor: false,
    logLevel: 'info',
  },
};
