/**
 * @spec: TASK-032
 * @epic: EPIC-009
 */
import fs from 'fs';
import os from 'os';
import path from 'path';
import type { RoutingResult } from './router.js';

const ROUTING_LOG = path.join(os.homedir(), '.orion', 'routing.log');

export interface RoutingLogEntry {
  timestamp: string;
  providerId: string;
  modelId: string;
  fallbackUsed: boolean;
  attemptsCount: number;
  promptTokens: number;
  completionTokens: number;
}

export function appendRoutingLog(result: RoutingResult): void {
  const entry: RoutingLogEntry = {
    timestamp: new Date().toISOString(),
    providerId: result.providerId,
    modelId: result.modelId,
    fallbackUsed: result.fallbackUsed,
    attemptsCount: result.attemptsCount,
    promptTokens: result.response.usage.promptTokens,
    completionTokens: result.response.usage.completionTokens,
  };
  fs.appendFileSync(ROUTING_LOG, JSON.stringify(entry) + '\n', { mode: 0o600 });
}

export function readRoutingLog(limit = 50): RoutingLogEntry[] {
  if (!fs.existsSync(ROUTING_LOG)) return [];
  const lines = fs.readFileSync(ROUTING_LOG, 'utf8').trim().split('\n').filter(Boolean);
  return lines
    .slice(-limit)
    .map((l) => {
      try { return JSON.parse(l) as RoutingLogEntry; } catch { return null; }
    })
    .filter((e): e is RoutingLogEntry => e !== null);
}
