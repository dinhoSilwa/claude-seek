# Backlog — Orion Multi-Provider AI Gateway

> Fonte de verdade para todo trabalho pendente. Ordenado por prioridade dentro de cada epic.

---

## Status legend
`planned` | `in-progress` | `review` | `done` | `blocked`

---

## EPIC-001 — Estabilização e bugs críticos
**Objetivo:** Corrigir problemas que afetam confiabilidade, segurança e manutenibilidade  
**Status:** planned

| Task | Tipo | Prioridade | Status |
|------|------|------------|--------|
| [TASK-001](tasks/TASK-001.md) — Sincronizar versão entre package.json e install script | fix | P0 | done |
| [TASK-002](tasks/TASK-002.md) — Substituir `source config.env` por parsing seguro | fix | P0 | done |
| [TASK-003](tasks/TASK-003.md) — Verificar e corrigir nomes dos modelos DeepSeek | fix | P1 | done |
| [TASK-004](tasks/TASK-004.md) — Expandir cobertura de testes bats | chore | P1 | done |

---

## EPIC-002 — UX e funcionalidades pendentes
**Objetivo:** Melhorar experiência do usuário e implementar comandos documentados mas ausentes  
**Status:** planned

| Task | Tipo | Prioridade | Status |
|------|------|------------|--------|
| [TASK-005](tasks/TASK-005.md) — Implementar comando `update` | feature | P1 | planned |
| [TASK-006](tasks/TASK-006.md) — Feedback visual durante seleção de modelo | feature | P2 | planned |
| [TASK-007](tasks/TASK-007.md) — Melhorar mensagens de erro (acionáveis) | fix | P2 | planned |

---

## EPIC-003 — Release e manutenibilidade
**Objetivo:** Profissionalizar o ciclo de release e rastreabilidade de mudanças  
**Status:** planned

| Task | Tipo | Prioridade | Status |
|------|------|------------|--------|
| [TASK-008](tasks/TASK-008.md) — Fixar versão do @anthropic-ai/claude-code | chore | P1 | planned |
| [TASK-009](tasks/TASK-009.md) — Criar script de release automatizado | chore | P2 | planned |
| [TASK-010](tasks/TASK-010.md) — Adicionar CHANGELOG.md | docs | P2 | planned |

---

## EPIC-004 — Windows Support
**Objetivo:** Definir e documentar (ou implementar) suporte real ao Windows  
**Status:** planned

| Task | Tipo | Prioridade | Status |
|------|------|------------|--------|
| [TASK-011](tasks/TASK-011.md) — Investigar suporte Windows sem WSL | chore | P2 | planned |
| [TASK-012](tasks/TASK-012.md) — Documentar limitação Windows no README | docs | P1 | planned |

---

## Prioridades

| Nível | Critério |
|-------|----------|
| P0 | Quebra funcionalidade existente ou expõe vulnerabilidade |
| P1 | Melhoria importante, sem workaround aceitável |
| P2 | Melhoria desejável, existe workaround |
| P3 | Nice to have, sem urgência |

---

---

## EPIC-005 — Arquitetura Multi-Provider (Reescrita TypeScript)
**Objetivo:** Base da reescrita em Node.js + TypeScript  
**Status:** planned

| Task | Tipo | Prioridade | Status |
|------|------|------------|--------|
| TASK-013 — Setup projeto TypeScript | chore | P0 | planned |
| TASK-014 — Interfaces TypeScript (Provider, Model, Message) | chore | P0 | planned |
| TASK-015 — BaseProvider abstrata | feat | P0 | planned |
| TASK-016 — CLI skeleton (Commander.js) | feat | P0 | planned |

---

## EPIC-006 — Gerenciamento de API Keys
**Objetivo:** Armazenamento seguro de múltiplas keys  
**Status:** planned

| Task | Tipo | Prioridade | Status |
|------|------|------------|--------|
| TASK-017 — Config store seguro | feat | P0 | planned |
| TASK-018 — Comandos config set/unset/show | feat | P0 | planned |
| TASK-019 — Ativação/desativação de providers | feat | P1 | planned |
| TASK-020 — Keys nunca em logs | fix | P0 | planned |

---

## EPIC-007 — Provider Adapters (MVP)
**Objetivo:** 6 adapters para MVP  
**Status:** planned

| Task | Tipo | Prioridade | Status |
|------|------|------------|--------|
| TASK-021 — Adapter DeepSeek | feat | P0 | planned |
| TASK-022 — Adapter OpenAI | feat | P0 | planned |
| TASK-023 — Adapter Anthropic | feat | P0 | planned |
| TASK-024 — Adapter OpenRouter | feat | P1 | planned |
| TASK-025 — Adapter Kimi (Moonshot) | feat | P1 | planned |
| TASK-026 — Adapter GLM | feat | P1 | planned |

---

## EPIC-008 — Registro e Padronização de Modelos
**Objetivo:** Catálogo unificado de modelos  
**Status:** planned

| Task | Tipo | Prioridade | Status |
|------|------|------------|--------|
| TASK-027 — Schema de Model | chore | P1 | planned |
| TASK-028 — Comando `orion models list` | feat | P1 | planned |
| TASK-029 — Normalização de capabilities | feat | P2 | planned |

---

## EPIC-009 — Roteamento Inteligente
**Objetivo:** Seleção automática e fallback entre providers  
**Status:** planned

| Task | Tipo | Prioridade | Status |
|------|------|------------|--------|
| TASK-030 — Regras de roteamento | feat | P1 | planned |
| TASK-031 — Fallback automático | feat | P0 | planned |
| TASK-032 — Log de roteamento | feat | P2 | planned |

---

## EPIC-010 — CLI Multi-Provider
**Objetivo:** Comandos providers/models e setup multi-provider  
**Status:** planned

| Task | Tipo | Prioridade | Status |
|------|------|------------|--------|
| TASK-033 — Comandos providers list/add/remove | feat | P0 | planned |
| TASK-034 — Wizard providers add | feat | P1 | planned |
| TASK-035 — Doctor multi-provider | feat | P1 | planned |
| TASK-036 — Setup multi-provider | feat | P1 | planned |

---

## Ordem de execução sugerida

```
TASK-001 → TASK-002 → TASK-003 → TASK-004   (EPIC-001, sequencial)
     ↓
TASK-008 → TASK-005 → TASK-012               (EPIC-002/003/004, pode ser paralelo)
     ↓
TASK-006 → TASK-007 → TASK-009 → TASK-010   (polimento final)
     ↓
TASK-011                                      (investigação longa, pode ser paralelo)
```
