import fs from 'fs';
import os from 'os';
import path from 'path';
import type { OrionConfig, ProviderCredential } from '../types/index.js';
import { DEFAULT_CONFIG } from '../types/index.js';

const CONFIG_DIR = path.join(os.homedir(), '.orion');
const CONFIG_FILE = path.join(CONFIG_DIR, 'config.json');

function ensureDir(): void {
  if (!fs.existsSync(CONFIG_DIR)) {
    fs.mkdirSync(CONFIG_DIR, { recursive: true, mode: 0o700 });
  }
}

export function readConfig(): OrionConfig {
  ensureDir();
  if (!fs.existsSync(CONFIG_FILE)) {
    return structuredClone(DEFAULT_CONFIG);
  }
  try {
    const raw = fs.readFileSync(CONFIG_FILE, 'utf8');
    return { ...structuredClone(DEFAULT_CONFIG), ...JSON.parse(raw) } as OrionConfig;
  } catch {
    return structuredClone(DEFAULT_CONFIG);
  }
}

export function writeConfig(config: OrionConfig): void {
  ensureDir();
  fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2), { mode: 0o600 });
}

export function setApiKey(providerId: string, apiKey: string): void {
  const config = readConfig();
  const existing = config.providers[providerId] ?? { apiKey: '', enabled: true };
  config.providers[providerId] = { ...existing, apiKey, enabled: true };
  writeConfig(config);
}

export function unsetApiKey(providerId: string): void {
  const config = readConfig();
  if (config.providers[providerId]) {
    delete config.providers[providerId];
    writeConfig(config);
  }
}

export function setProviderEnabled(providerId: string, enabled: boolean): void {
  const config = readConfig();
  if (!config.providers[providerId]) {
    throw new Error(`Provider '${providerId}' is not configured.`);
  }
  config.providers[providerId] = { ...config.providers[providerId], enabled } as ProviderCredential;
  writeConfig(config);
}

export function getProviderCredential(providerId: string): ProviderCredential | undefined {
  return readConfig().providers[providerId];
}

export function listConfiguredProviders(): Array<{ id: string; credential: ProviderCredential }> {
  const config = readConfig();
  return Object.entries(config.providers).map(([id, credential]) => ({ id, credential }));
}

export function redactKey(apiKey: string): string {
  if (!apiKey || apiKey.length < 8) return '***';
  return `${apiKey.slice(0, 4)}${'*'.repeat(apiKey.length - 8)}${apiKey.slice(-4)}`;
}
