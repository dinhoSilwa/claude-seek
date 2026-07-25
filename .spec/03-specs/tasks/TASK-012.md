# TASK-012 — Documentar limitação Windows no README

- **Epic:** EPIC-004
- **Phase:** PHASE-007
- **Tipo:** docs
- **Status:** planned
- **Bloqueado por:** TASK-011 (decisão de ADR)

## Contexto
O README não menciona a limitação de suporte ao Windows. Usuários Windows que instalam via npm encontram o wrapper bash e não conseguem executar sem Git Bash ou WSL.

## Descrição
Atualizar README com seção de compatibilidade clara.

**Conteúdo mínimo (se decisão for documentar limitação):**
```markdown
## Compatibility

| OS | Support |
|----|---------|
| Linux | Full support |
| macOS | Full support |
| Windows (WSL2) | Supported |
| Windows (Git Bash) | Supported |
| Windows (native) | Not supported |
```

**Se decisão for implementar suporte nativo:** esta task vira implementação do wrapper PowerShell/cmd.

## Arquivos relevantes
- `README.md` — adicionar seção Compatibility após Prerequisites
- `.github/workflows/test.yml` — ajustar matriz conforme decisão

## Definition of Done
- [ ] README tem seção de compatibilidade clara
- [ ] CI alinhado com compatibilidade documentada
- [ ] Commit: `[TASK-012] docs: documentar compatibilidade de SO`
