import { Command } from 'commander';
import readline from 'readline';
import { spawn } from 'child_process';
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
  getProviderCredential,
} from '../config/index.js';
import { ModelRegistry } from '../models/index.js';
import { buildAllConfiguredProviders, buildProvider, getDefaultModel, SUPPORTED_PROVIDERS } from './provider-factory.js';
import { startProxy } from '../proxy/index.js';
import type { ModelCapability } from '../types/index.js';

// Providers with native Anthropic Messages API — no proxy needed
const NATIVE_ANTHROPIC_PROVIDERS = new Set(['anthropic']);

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
const pkg = require(path.join(__dirname, '../../package.json')) as { version: string };

function promptSecret(question: string): Promise<string> {
  return new Promise((resolve) => {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
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

async function launchClaude(providerId: string, extraArgs: string[]): Promise<void> {
  const cred = getProviderCredential(providerId);
  if (!cred?.apiKey) {
    console.error(`Provider '${providerId}' is not configured. Run: orion providers add ${providerId}`);
    process.exit(1);
  }

  const model = cred.defaultModel ?? getDefaultModel(providerId);
  let env: NodeJS.ProcessEnv;

  if (NATIVE_ANTHROPIC_PROVIDERS.has(providerId)) {
    // Anthropic native — pass key directly, no proxy
    env = { ...process.env, ANTHROPIC_API_KEY: cred.apiKey };
    if (cred.baseUrl) env['ANTHROPIC_BASE_URL'] = cred.baseUrl;
  } else {
    // Non-native provider — start translation proxy
    process.stdout.write(`Starting Orion proxy for ${providerId}... `);
    const { port, server } = await startProxy(providerId, cred);
    console.log(`OK (port ${port})`);

    env = {
      ...process.env,
      ANTHROPIC_API_KEY: 'orion-proxy',
      ANTHROPIC_BASE_URL: `http://127.0.0.1:${port}`,
    };

    // shut down proxy when claude exits
    process.on('exit', () => server.close());
    process.on('SIGINT', () => { server.close(); process.exit(0); });
    process.on('SIGTERM', () => { server.close(); process.exit(0); });
  }

  const args = ['--model', model, ...extraArgs];
  const child = spawn('claude', args, { stdio: 'inherit', env });

  child.on('error', (err) => {
    if ((err as NodeJS.ErrnoException).code === 'ENOENT') {
      console.error('Claude Code not found. Install it: npm install -g @anthropic-ai/claude-code');
    } else {
      console.error(`Failed to launch claude: ${err.message}`);
    }
    process.exit(1);
  });

  child.on('exit', (code) => process.exit(code ?? 0));
}

export function createCLI(): Command {
  const program = new Command();

  program
    .name('orion')
    .description('AI coding assistant — launches Claude Code with your configured provider')
    .version(pkg.version, '-v, --version', 'output the current version')
    .option('-p, --provider <id>', 'provider to use (overrides default)')
    .allowUnknownOption(true)
    .allowExcessArguments(true)
    .action(async (_options: { provider?: string }) => {
      const config = readConfig();
      const providerId = _options.provider ?? config.defaultProvider;

      if (!providerId) {
        console.error('No provider configured. Run: orion setup');
        process.exit(1);
      }

      // pass through any extra args (e.g. --resume, --debug) to claude
      const extraArgs = process.argv.slice(2).filter(
        (a) => a !== '-p' && a !== '--provider' && a !== _options.provider,
      );

      await launchClaude(providerId, extraArgs);
    });

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
        console.log(`  ${id.padEnd(12)} ${status}   key: ${redactKey(credential.apiKey)}`);
      }
    }),
  );

  providersCmd.addCommand(
    new Command('add')
      .description('add or update a provider')
      .argument('<provider>', `provider id (${SUPPORTED_PROVIDERS.join(', ')})`)
      .action(async (provider: string) => {
        if (!SUPPORTED_PROVIDERS.includes(provider)) {
          console.error(`Unknown provider: ${provider}\nSupported: ${SUPPORTED_PROVIDERS.join(', ')}`);
          process.exit(1);
        }
        const apiKey = await promptSecret(`Enter API key for ${provider}: `);
        if (!apiKey.trim()) { console.error('API key cannot be empty.'); process.exit(1); }
        setApiKey(provider, apiKey.trim());
        console.log(`Provider '${provider}' configured.`);
      }),
  );

  providersCmd.addCommand(
    new Command('remove')
      .description('remove a provider')
      .argument('<provider>', 'provider id')
      .action((provider: string) => { unsetApiKey(provider); console.log(`Provider '${provider}' removed.`); }),
  );

  providersCmd.addCommand(
    new Command('enable')
      .description('enable a provider')
      .argument('<provider>', 'provider id')
      .action((provider: string) => {
        try { setProviderEnabled(provider, true); console.log(`Provider '${provider}' enabled.`); }
        catch (e) { console.error((e as Error).message); process.exit(1); }
      }),
  );

  providersCmd.addCommand(
    new Command('disable')
      .description('disable a provider')
      .argument('<provider>', 'provider id')
      .action((provider: string) => {
        try { setProviderEnabled(provider, false); console.log(`Provider '${provider}' disabled.`); }
        catch (e) { console.error((e as Error).message); process.exit(1); }
      }),
  );

  program.addCommand(providersCmd);

  // --- config ---
  const configCmd = new Command('config').description('manage configuration');

  configCmd.addCommand(
    new Command('set-key')
      .description('set API key for a provider')
      .argument('<provider>', 'provider id')
      .action(async (provider: string) => {
        if (!SUPPORTED_PROVIDERS.includes(provider)) { console.error(`Unknown provider: ${provider}`); process.exit(1); }
        const apiKey = await promptSecret(`Enter API key for ${provider}: `);
        if (!apiKey.trim()) { console.error('API key cannot be empty.'); process.exit(1); }
        setApiKey(provider, apiKey.trim());
        console.log(`Key for '${provider}' saved.`);
      }),
  );

  configCmd.addCommand(
    new Command('unset-key')
      .description('remove API key for a provider')
      .argument('<provider>', 'provider id')
      .action((provider: string) => { unsetApiKey(provider); console.log(`Key for '${provider}' removed.`); }),
  );

  configCmd.addCommand(
    new Command('show').description('show configuration (keys redacted)').action(() => {
      const config = readConfig();
      const safe = {
        ...config,
        providers: Object.fromEntries(
          Object.entries(config.providers).map(([id, cred]) => [id, { ...cred, apiKey: redactKey(cred.apiKey) }]),
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
          console.error(`Provider '${provider}' not configured. Run: orion providers add ${provider}`);
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
    .option('--capability <cap>', 'filter by capability')
    .action(async (options: { provider?: string; capability?: string }) => {
      const providers = buildAllConfiguredProviders();
      if (providers.length === 0) { console.log('No providers configured. Run: orion setup'); return; }

      const filtered = options.provider ? providers.filter((p) => p.id === options.provider) : providers;
      if (filtered.length === 0) { console.error(`No configured provider matches: ${options.provider}`); process.exit(1); }

      const registry = new ModelRegistry();
      await registry.loadAll(filtered);
      const models = options.capability ? registry.byCapability(options.capability as ModelCapability) : registry.all();

      if (models.length === 0) { console.log('No models found.'); return; }
      console.log(`\nAvailable models (${models.length}):\n`);
      for (const m of models) {
        const ctx = `${Math.round(m.contextWindow / 1000)}k`;
        const price = m.pricing ? `  $${m.pricing.inputPer1M}/$${m.pricing.outputPer1M}/1M` : '';
        const def = m.isDefault ? ' *' : '';
        console.log(`  ${m.provider.padEnd(12)} ${m.id.padEnd(32)} ctx:${ctx.padEnd(6)}${price}${def}`);
      }
    });

  // --- doctor ---
  program
    .command('doctor')
    .description('check provider connectivity')
    .action(async () => {
      console.log('Orion doctor\n');
      const configured = listConfiguredProviders();
      if (configured.length === 0) { console.log('No providers configured.\nRun: orion setup'); return; }
      for (const { id, credential } of configured) {
        if (!credential.enabled) { console.log(`  - ${id.padEnd(12)} disabled`); continue; }
        const provider = buildProvider(id);
        if (!provider) { console.log(`  ? ${id.padEnd(12)} unknown`); continue; }
        process.stdout.write(`  checking ${id.padEnd(12)} ... `);
        try {
          const ok = await provider.validateApiKey(credential.apiKey);
          console.log(ok ? 'OK' : 'FAIL — invalid API key');
        } catch { console.log('FAIL — connection error'); }
      }
    });

  // --- setup ---
  program
    .command('setup')
    .description('interactive setup wizard')
    .action(async () => {
      console.log('Orion Setup Wizard\n');
      console.log(`Supported providers: ${SUPPORTED_PROVIDERS.join(', ')}\n`);
      const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
      const ask = (q: string): Promise<string> => new Promise((resolve) => rl.question(q, resolve));
      const providerInput = await ask('Which provider do you want to add? ');
      const providerId = providerInput.trim().toLowerCase();
      if (!SUPPORTED_PROVIDERS.includes(providerId)) {
        console.error(`\nUnknown provider: ${providerId}`); rl.close(); process.exit(1);
      }
      rl.close();
      const apiKey = await promptSecret(`Enter API key for ${providerId}: `);
      if (!apiKey.trim()) { console.error('API key cannot be empty.'); process.exit(1); }
      setApiKey(providerId, apiKey.trim());
      const config = readConfig();
      if (!config.defaultProvider) { config.defaultProvider = providerId; writeConfig(config); }
      console.log(`\nProvider '${providerId}' configured. Run: orion`);
    });

  return program;
}
