# Architecture — orion

> Este projeto é uma ferramenta CLI pura em Bash. Não há frontend, backend web ou banco de dados. A arquitetura é de scripts shell.

## Fluxo principal

```
npm install -g orion
        │
        ▼
bin/orion (wrapper npm)
        │
        ├─ ~/.orion/orion existe?
        │       │
        │      NÃO → executa install-orion.sh
        │               │
        │               ├─ verifica Node.js + npm
        │               ├─ cria ~/.orion/
        │               ├─ npm install @anthropic-ai/claude-code
        │               └─ gera ~/.orion/orion (wrapper real)
        │
        └─ exec ~/.orion/orion "$@"
                │
                ├─ parse argumentos (setup / config / history / doctor / --help / --version)
                │
                └─ fluxo principal:
                        ├─ get_api_key()        — env var ou arquivo key
                        ├─ validate_api_key()   — teste real na API
                        ├─ select_model()       — fallback: pro → flash → chat
                        ├─ save_session()       — se HISTORY_ENABLED=true
                        ├─ export ANTHROPIC_BASE_URL / AUTH_TOKEN / MODEL
                        └─ exec node_modules/.bin/claude "${ARGS[@]}"
```

## Módulos (funções bash)

| Módulo | Funções | Responsabilidade |
|--------|---------|-----------------|
| API Key | `get_api_key`, `save_api_key`, `remove_api_key` | Persistência segura da chave |
| API | `call_deepseek_api`, `validate_api_key`, `test_model` | Comunicação com DeepSeek |
| Model | `select_model` | Seleção com fallback |
| Session | `get_session_id`, `save_session`, `list_sessions`, `show_session`, `clear_history` | Histórico de uso |
| Setup | `run_setup` | Wizard interativo |
| Commands | `cmd_set_key`, `cmd_unset_key`, `cmd_show_config`, `cmd_doctor`, `cmd_help` | Subcomandos CLI |

## Armazenamento

```
~/.orion/
├── orion          # executável gerado pelo install
├── node_modules/        # @anthropic-ai/claude-code (instalado pelo npm)
├── package.json         # projeto npm local (private: true)
├── key                  # API key em texto plano (chmod 600)
├── config.env           # variáveis de configuração
├── history/
│   └── YYYYMMDD_HHMMSS_PID.session   # metadados de sessão
└── logs/
    └── orion-YYYYMMDD.log      # logs diários
```

## Dependência externa crítica
`@anthropic-ai/claude-code` — o binário real que faz o trabalho de assistente de código. O orion apenas configura o ambiente e delega com `exec`.

## Pontos de falha conhecidos
1. `select_model` faz 3 chamadas HTTP sequenciais na inicialização (lento se API estiver instável)
2. `source config.env` permite execução de código arbitrário (ver TASK-002)
3. Versão do `@anthropic-ai/claude-code` não é fixada — pode quebrar com updates
