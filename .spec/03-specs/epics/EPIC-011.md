# EPIC-011 — Proxy Local Anthropic↔OpenAI

- **Objetivo:** Permitir que qualquer provider OpenAI-compatible funcione com Claude Code via proxy de tradução de protocolo
- **Status:** in-progress
- **Depende de:** EPIC-006, EPIC-007

## Problema

Claude Code usa o SDK da Anthropic (Anthropic Messages API format).
Providers como Kimi, GLM, OpenRouter e OpenAI usam OpenAI Chat Completions format.
São protocolos diferentes e incompatíveis diretamente.

## Solução

O Orion sobe um servidor HTTP local antes de lançar o `claude`, configurando:
- `ANTHROPIC_BASE_URL=http://127.0.0.1:<porta>`
- O proxy traduz Anthropic → OpenAI → Anthropic em tempo real

## Tasks

- [ ] TASK-037 — Tradução de formato request/response (Anthropic ↔ OpenAI)
- [ ] TASK-038 — Tradução de streaming SSE (Anthropic ↔ OpenAI)
- [ ] TASK-039 — Servidor HTTP proxy com roteamento por provider
- [ ] TASK-040 — Integração com CLI: proxy sobe antes do claude, desce junto

## Critérios de conclusão

- `orion` com Kimi/OpenAI/GLM abre Claude Code e responde normalmente
- Streaming funciona (texto aparece progressivamente)
- Proxy para quando o claude fecha
- Providers nativos (Anthropic) não passam pelo proxy
