# EPIC-007 — Provider Adapters (MVP)

- **Objetivo:** Implementar adapters individuais para os 6 providers do MVP
- **Status:** planned
- **Depende de:** EPIC-005, EPIC-006

## Providers MVP
| Provider | Formato API | Task |
|----------|-------------|------|
| DeepSeek | OpenAI-like | TASK-021 |
| OpenAI | OpenAI | TASK-022 |
| Anthropic | Anthropic | TASK-023 |
| OpenRouter | OpenAI | TASK-024 |
| Kimi (Moonshot AI) | OpenAI-like | TASK-025 |
| GLM (Zhipu AI) | OpenAI-like | TASK-026 |

## Tasks
- [ ] TASK-021 — Adapter: DeepSeek
- [ ] TASK-022 — Adapter: OpenAI
- [ ] TASK-023 — Adapter: Anthropic
- [ ] TASK-024 — Adapter: OpenRouter
- [ ] TASK-025 — Adapter: Kimi (Moonshot AI)
- [ ] TASK-026 — Adapter: GLM (Zhipu AI)

## Critérios de conclusão
- Cada adapter: listagem de modelos, validação de key, chat completion
- Testes unitários com mock de API para cada adapter
- `orion providers list` mostra providers configurados
