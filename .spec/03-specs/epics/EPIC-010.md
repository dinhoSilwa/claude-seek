# EPIC-010 — CLI Multi-Provider

- **Objetivo:** Adaptar e expandir os comandos da CLI para o contexto multi-provider
- **Status:** planned
- **Depende de:** EPIC-006, EPIC-007, EPIC-008

## Comandos novos

```bash
orion providers list              # listar providers configurados
orion providers add <provider>    # adicionar provider (wizard)
orion providers remove <provider> # remover provider

orion models list                 # listar modelos disponíveis
orion models list --provider openai
orion models list --capability vision

orion config set-key <provider>   # configurar key de um provider
orion config show                 # exibir configuração atual
orion doctor                      # health check multi-provider
```

## Tasks
- [ ] TASK-033 — Comandos `orion providers list/add/remove`
- [ ] TASK-034 — Wizard interativo para `providers add`
- [ ] TASK-035 — Atualizar `orion doctor` para checar todos os providers
- [ ] TASK-036 — Atualizar `orion setup` para fluxo multi-provider

## Critérios de conclusão
- Todos os comandos funcionam e têm `--help`
- `orion doctor` exibe status de cada provider configurado
- Setup wizard guia pelo cadastro do primeiro provider
