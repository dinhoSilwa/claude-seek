import { Command } from 'commander';
import readline from 'readline';
import { createRequire } from 'module';
import path from 'path';
import { fileURLToPath } from 'url';
import {
  setApiKey,
  unsetApiKey,
  setProviderEnabled,
  listConfiguredProviders,
  readConfig,
  writeConfig,
  redactKey,
} from '../config/index.js';
import { ModelRegistry } from '../models/index.js';
import { buildAllConfiguredProviders, SUPPORTED_PROVIDERS } from './provider-factory.js';
import type { ModelCapability } from '../types/index.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
const pkg = require(path.join(__dirname, '../../package.json')) as { version: string };

function promptSecret(question: string): Promise<string> {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    process.stdout.write(question);
    process.stdin.setRawMode?.(true);

    let key = '';
    process.stdin.on('data', function handler(char: Buffer) {
      const ch = char.toString();
      if (ch === '\r' || ch === '\n') {
        process.stdin.setRawMode?.(false);
        process.stdin.removeListener('data', handler);
        process.stdout.write('\n');
        rl.close();
        resolve(key);
      } else if (ch === '\x7f') {
        key = key.slice(0, -1);
      } else if (ch === '\x03') {
        process.stdout.write('\n');
        process.exit(0);
      } else {
        key += ch;
        process.stdout.write('*');
      }
    });
  });
}

export function createCLI(): Command {
  const program = new Command();

  program
    .name('orion')
    .description('AI coding assistant with multi-provider support')
    .version(pkg.version, '-v, --version', 'output the current version');

  // --- providers ---
  const providersCmd = new Command('providers').description('manage AI providers');

  providersCmd.addCommand(
    new Command('list').description('list configured providers').action(() => {
      const providers = listConfiguredProviders();
      if (providers.length === 0) {
        console.log('No providers configured.\nRun: orion providers add <provider>');
        console.log(`\nSupported: ${SUPPORTED_PROVIDERS.join(', ')}`);
        return;
      }
      console.log('Configured providers:\n');
      for (const { id, credential } of providers) {
        const status = credential.enabled ? '✓ enabled' : '✗ disabled';
        const key = redactKey(credential.apiKey);
        console.log(`  ${id.padEnd(12)} ${status}   key: ${key}`);
      }
    }),
  );

  providersCmd.addCommand(
    new Command('add')
      .description('add or update a provider')
      .argument('<provider>', `provider id (${SUPPORTED_PROVIDERS.join(', ')})`)
      .action(async (provider: string) => {
        if (!SUPPORTED_PROVIDERS.includes(provider)) {
          console.error(`Unknown provider: ${provider}`);
          console.error(`Supported: ${SUPPORTED_PROVIDERS.join(', ')}`);
          process.exit(1);
        }
        const apiKey = await promptSecret(`Enter API key for ${provider}: `);
        if (!apiKey.trim()) {
          console.error('API key cannot be empty.');
          process.exit(1);
        }
        setApiKey(provider, apiKey.trim());
        console.log(`Provider '${provider}' configured successfully.`);
      }),
  );

  providersCmd.addCommand(
    new Command('remove')
      .description('remove a provider')
      .argument('<provider>', 'provider id')
      .action((provider: string) => {
        unsetApiKey(provider);
        console.log(`Provider '${provider}' removed.`);
      }),
  );

  providersCmd.addCommand(
    new Command('enable')
      .description('enable a configured provider')
      .argument('<provider>', 'provider id')
      .action((provider: string) => {
        try {
          setProviderEnabled(provider, true);
          console.log(`Provider '${provider}' enabled.`);
        } catch (e) {
          console.error((e as Error).message);
          process.exit(1);
        }
      }),
  );

  providersCmd.addCommand(
    new Command('disable')
      .description('disable a provider without removing its key')
      .argument('<provider>', 'provider id')
      .action((provider: string) => {
        try {
          setProviderEnabled(provider, false);
          console.log(`Provider '${provider}' disabled.`);
        } catch (e) {
          console.error((e as Error).message);
          process.exit(1);
        }
      }),
  );

  program.addCommand(providersCmd);

  // --- config ---
  const configCmd = new Command('config').description('manage configuration');

  configCmd.addCommand(
    new Command('set-key')
      .description('set API key for a provider (alias for: orion providers add)')
      .argument('<provider>', 'provider id')
      .action(async (provider: string) => {
        if (!SUPPORTED_PROVIDERS.includes(provider)) {
          console.error(`Unknown provider: ${provider}`);
          process.exit(1);
        }
        const apiKey = await promptSecret(`Enter API key for ${provider}: `);
        if (!apiKey.trim()) {
          console.error('API key cannot be empty.');
          process.exit(1);
        }
        setApiKey(provider, apiKey.trim());
        console.log(`Key for '${provider}' saved.`);
      }),
  );

  configCmd.addCommand(
    new Command('unset-key')
      .description('remove the API key for a provider')
      .argument('<provider>', 'provider id')
      .action((provider: string) => {
        unsetApiKey(provider);
        console.log(`Key for '${provider}' removed.`);
      }),
  );

  configCmd.addCommand(
    new Command('show').description('show current configuration (keys are redacted)').action(() => {
      const config = readConfig();
      const safe = {
        ...config,
        providers: Object.fromEntries(
          Object.entries(config.providers).map(([id, cred]) => [
            id,
            { ...cred, apiKey: redactKey(cred.apiKey) },
          ]),
        ),
      };
      console.log(JSON.stringify(safe, null, 2));
    }),
  );

  configCmd.addCommand(
    new Command('set-default')
      .description('set the default provider')
      .argument('<provider>', 'provider id')
      .action((provider: string) => {
        const config = readConfig();
        if (!config.providers[provider]) {
          console.error(`Provider '${provider}' is not configured. Run: orion providers add ${provider}`);
          process.exit(1);
        }
        config.defaultProvider = provider;
        writeConfig(config);
        console.log(`Default provider set to '${provider}'.`);
      }),
  );

  program.addCommand(configCmd);

  // --- models ---
  program
    .command('models')
    .description('list available models')
    .option('--provider <id>', 'filter by provider')
    .option('--capability <cap>', 'filter by capability (chat, code, vision, embeddings, function_calling, streaming)')
    .action(async (options: { provider?: string; capability?: string }) => {
      const providers = buildAllConfiguredProviders();
      if (providers.length === 0) {
        console.log('No providers configured. Run: orion providers add <provider>');
        return;
      }

      const filtered = options.provider
        ? providers.filter((p) => p.id === options.provider)
        : providers;

      if (filtered.length === 0) {
        console.error(`No configured provider matches: ${options.provider}`);
        process.exit(1);
      }

      const registry = new ModelRegistry();
      await registry.loadAll(filtered);

      let models = options.capability
        ? registry.byCapability(options.capability as ModelCapability)
        : registry.all();

      if (models.length === 0) {
        console.log('No models found matching the given filters.');
        return;
      }

      console.log(`\nAvailable models (${models.length}):\n`);
      for (const m of models) {
        const caps = m.capabilities.join(', ');
        const ctx = `${Math.round(m.contextWindow / 1000)}k`;
        const price = m.pricing
          ? `  $${m.pricing.inputPer1M}/$${m.pricing.outputPer1M} per 1M tokens`
          : '';
        const def = m.isDefault ? ' (default)' : '';
        console.log(`  ${m.provider.padEnd(12)} ${m.id.padEnd(32)} ctx:${ctx.padEnd(6)}${price}${def}`);
        console.log(`  ${''.padEnd(12)} capabilities: ${caps}\n`);
      }
    });

  // --- doctor ---
  program
    .command('doctor')
    .description('check system health and provider connectivity')
    .action(() => {
      const providers = listConfiguredProviders();
      console.log('Orion doctor\n');
      if (providers.length === 0) {
        console.log('No providers configured.');
        console.log('Run: orion providers add <provider>');
        return;
      }
      console.log('Configured providers:');
      for (const { id, credential } of providers) {
        const status = credential.enabled ? '✓' : '✗';
        console.log(`  ${status} ${id}`);
      }
      console.log('\nFull connectivity check coming in EPIC-010.');
    });

  return program;
}
