# Tech Stack

## Runtime
- Node.js 18+ (requisito mínimo)
- npm 9+

## Linguagens
- **TypeScript** — código-fonte principal
- **JavaScript (CommonJS/ESM)** — output compilado
- **Bash** — scripts de instalação legados (install-orion.sh)

## Estrutura do projeto (target)
```
src/
├── cli/           # Entry point e handlers de comandos
├── providers/     # Adapters por fornecedor
│   ├── base.ts    # Interface/classe abstrata Provider
│   ├── deepseek.ts
│   ├── openai.ts
│   ├── anthropic.ts
│   ├── openrouter.ts
│   ├── kimi.ts
│   └── glm.ts
├── config/        # Gerenciamento de configuração e keys
├── router/        # Roteamento inteligente e fallback
├── models/        # Registro de modelos
└── types/         # Interfaces TypeScript compartilhadas
bin/
└── orion.js       # CLI entry (Node.js, shebang #!/usr/bin/env node)
```

## Dependências planejadas (MVP)
| Pacote | Uso |
|--------|-----|
| `commander` ou `@oclif/core` | Framework CLI |
| `openai` | SDK OpenAI (compatível com vários providers) |
| `@anthropic-ai/sdk` | SDK Anthropic direto |
| `inquirer` ou `@inquirer/prompts` | Prompts interativos (setup wizard) |
| `conf` ou `keytar` | Armazenamento seguro de configuração |
| `chalk` | Output colorido |
| `ora` | Spinners de progresso |

## Ferramentas de build
- **TypeScript** (`tsc`)
- **tsup** ou **esbuild** — bundle rápido

## Ferramentas de qualidade
- **ESLint** + `@typescript-eslint`
- **Prettier**
- **Vitest** — testes unitários

## CI/CD
- **GitHub Actions** — `.github/workflows/test.yml`
- Matrix: Ubuntu + macOS × Node 18/20/22

## MVP Providers
| Provider | Base URL | Auth | Compat |
|----------|----------|------|--------|
| DeepSeek | `https://api.deepseek.com` | Bearer | OpenAI-like |
| OpenAI | `https://api.openai.com` | Bearer | OpenAI |
| Anthropic | `https://api.anthropic.com` | x-api-key | Anthropic |
| OpenRouter | `https://openrouter.ai/api` | Bearer | OpenAI |
| Kimi (Moonshot) | `https://api.moonshot.cn` | Bearer | OpenAI-like |
| GLM | `https://open.bigmodel.cn` | Bearer | OpenAI-like |

## Distribuição
- **npm** — `npm install -g orion-code`
- **git clone** — `./install-orion.sh`
