import { Command } from 'commander';
import { createRequire } from 'module';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
const pkg = require(path.join(__dirname, '../../package.json')) as { version: string; name: string };

export function createCLI(): Command {
  const program = new Command();

  program
    .name('orion')
    .description('AI coding assistant with multi-provider support')
    .version(pkg.version, '-v, --version', 'output the current version');

  program
    .command('providers')
    .description('manage AI providers')
    .addCommand(
      new Command('list').description('list configured providers').action(() => {
        console.log('No providers configured. Run: orion providers add');
      }),
    )
    .addCommand(
      new Command('add')
        .description('add a provider')
        .argument('<provider>', 'provider id (deepseek, openai, anthropic, openrouter, kimi, glm)')
        .action((provider: string) => {
          console.log(`Adding provider: ${provider} (not yet implemented)`);
        }),
    )
    .addCommand(
      new Command('remove')
        .description('remove a provider')
        .argument('<provider>', 'provider id')
        .action((provider: string) => {
          console.log(`Removing provider: ${provider} (not yet implemented)`);
        }),
    );

  program
    .command('models')
    .description('list available models')
    .option('--provider <id>', 'filter by provider')
    .option('--capability <cap>', 'filter by capability')
    .action((_options: { provider?: string; capability?: string }) => {
      console.log('Model registry not yet implemented. Coming in EPIC-008.');
    });

  program
    .command('config')
    .description('manage configuration')
    .addCommand(
      new Command('set-key')
        .description('set API key for a provider')
        .argument('<provider>', 'provider id')
        .action((provider: string) => {
          console.log(`Setting key for ${provider} (not yet implemented)`);
        }),
    )
    .addCommand(
      new Command('show').description('show current configuration').action(() => {
        console.log('Configuration management not yet implemented. Coming in EPIC-006.');
      }),
    );

  program
    .command('doctor')
    .description('check system health and provider connectivity')
    .action(() => {
      console.log('Orion doctor — multi-provider health check not yet implemented. Coming in EPIC-010.');
    });

  return program;
}
