# EPIC-005 — Arquitetura Multi-Provider (Reescrita TypeScript)

- **Objetivo:** Reescrever o Orion em Node.js + TypeScript com estrutura modular que suporta múltiplos providers de IA via chamadas diretas de API
- **Status:** planned
- **Bloqueia:** EPIC-006, EPIC-007, EPIC-008, EPIC-009, EPIC-010

## Fases
- [ ] PHASE-008 — Setup do projeto TypeScript
- [ ] PHASE-009 — Interface base de providers

## Tasks
- [ ] TASK-013 — Inicializar projeto TypeScript (tsconfig, build, lint)
- [ ] TASK-014 — Definir interfaces TypeScript (Provider, Model, Message, Config)
- [ ] TASK-015 — Implementar classe abstrata BaseProvider
- [ ] TASK-016 — Implementar CLI skeleton com Commander.js

## Critérios de conclusão
- Projeto compila sem erros
- CLI responde a `orion --help` e `orion --version`
- BaseProvider implementada e testada
