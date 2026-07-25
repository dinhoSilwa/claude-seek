# EPIC-003 — Release e manutenibilidade

- **Objetivo:** Profissionalizar o ciclo de release com rastreabilidade de mudanças e processo automatizado
- **Status:** planned

## Tasks
- [ ] TASK-008 — Fixar versão do @anthropic-ai/claude-code
- [ ] TASK-009 — Criar script de release automatizado
- [ ] TASK-010 — Adicionar CHANGELOG.md

## Critérios de conclusão
- Versão do `@anthropic-ai/claude-code` fixada no install script
- `./scripts/release.sh patch|minor|major` atualiza versão em todos os arquivos e cria tag git
- CHANGELOG.md atualizado a cada release
