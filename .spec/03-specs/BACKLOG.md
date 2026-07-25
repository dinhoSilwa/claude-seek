# Backlog — orion

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
