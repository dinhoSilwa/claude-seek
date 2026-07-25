export type ModelCapability =
  | 'chat'
  | 'code'
  | 'vision'
  | 'embeddings'
  | 'function_calling'
  | 'streaming';

export interface ModelPricing {
  inputPer1M: number;
  outputPer1M: number;
  currency: 'USD';
}

export interface Model {
  id: string;
  name: string;
  provider: string;
  contextWindow: number;
  capabilities: ModelCapability[];
  pricing?: ModelPricing;
  isDefault?: boolean;
}
