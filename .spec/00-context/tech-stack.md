# Tech Stack

## Runtime
- Node.js 18+ (requisito mínimo para `@anthropic-ai/claude-code`)
- npm (vem com Node.js)

## Linguagens
- **Bash** — scripts principais (`install-orion.sh`, `uninstall-orion.sh`, wrapper `bin/orion`)
- **JSON** — `package.json`, configs gerados em runtime

## Dependência principal
| Pacote | Versão | Papel |
|--------|--------|-------|
| `@anthropic-ai/claude-code` | latest | CLI Claude Code — instalado em `~/.orion/node_modules/` no primeiro uso |

Sem outras dependências de produção. O `package.json` do repositório não declara `dependencies`.

## Distribuição
- **npm** — `npm install -g orion` (recomendado)
- **yarn** — `yarn global add orion`
- **git clone** — execução direta de `install-orion.sh`

## Mecanismo central
```bash
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="$API_KEY"
export ANTHROPIC_MODEL="$SELECTED_MODEL"
exec "$SCRIPT_DIR/node_modules/.bin/claude" "${ARGS[@]}"
```
O Claude Code aceita base URL customizada, permitindo substituir o provedor.

## Modelos suportados (fallback em ordem)
1. `deepseek-v4-pro`
2. `deepseek-v4-flash` (fallback final)

> `deepseek-chat` e `deepseek-reasoner` foram deprecados em 2026-07-24.

## Armazenamento em runtime
```
~/.orion/
├── orion        # executável principal (gerado pelo install)
├── node_modules/      # @anthropic-ai/claude-code
├── key                # API key (chmod 600)
├── config.env         # configurações do usuário
├── history/           # arquivos .session
└── logs/              # logs diários
```

## Ferramentas de qualidade
- **shellcheck** — lint dos scripts Bash (`install-orion.sh`, `uninstall-orion.sh`)
- **bats** (Bash Automated Testing System) — testes dos scripts

## CI/CD
- **GitHub Actions** — `.github/workflows/test.yml`
- Matrix: Ubuntu + macOS + Windows × Node 18/20/22
- Windows: apenas verifica instalação via bash, sem testes bats
