# EPIC-008 — Registro e Padronização de Modelos

- **Objetivo:** Catálogo unificado de modelos disponíveis por provider, com capacidades normalizadas
- **Status:** planned
- **Depende de:** EPIC-007

## Tasks
- [ ] TASK-027 — Definir schema de Model (id, provider, capabilities, context window, pricing)
- [ ] TASK-028 — Comando `orion models list` com filtro por provider e capability
- [ ] TASK-029 — Capabilities: chat, code, vision, embeddings, function_calling, streaming

## Critérios de conclusão
- `orion models list` exibe modelos de todos os providers configurados
- `orion models list --provider deepseek` filtra por provider
- `orion models list --capability vision` filtra por capacidade
