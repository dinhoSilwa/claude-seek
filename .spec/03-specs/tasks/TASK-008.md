# TASK-008 — Fixar versão do @anthropic-ai/claude-code

- **Epic:** EPIC-003
- **Phase:** PHASE-006
- **Tipo:** chore
- **Status:** planned

## Contexto
`install-claude-seek.sh` executa `npm install @anthropic-ai/claude-code` sem fixar versão, instalando sempre a mais recente. Uma atualização do Claude Code pode remover suporte às variáveis `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` e quebrar o projeto silenciosamente.

## Descrição
Definir a versão mínima testada e compatível do `@anthropic-ai/claude-code` no install script.

**Abordagem:**
```bash
# Em vez de:
npm install @anthropic-ai/claude-code

# Usar:
CLAUDE_CODE_VERSION="1.x.x"  # versão mínima compatível verificada
npm install "@anthropic-ai/claude-code@^${CLAUDE_CODE_VERSION}"
```

Documentar em `tech-stack.md` a versão mínima e como atualizar.

## Arquivos relevantes
- `install-claude-seek.sh` — linha ~58 (`npm install @anthropic-ai/claude-code`)
- `.spec/00-context/tech-stack.md` — atualizar com versão fixada

## Definition of Ready
- [ ] Verificar versão atual do `@anthropic-ai/claude-code` no npm
- [ ] Testar que as variáveis de ambiente são respeitadas na versão alvo

## Definition of Done
- [ ] Versão fixada com range semver seguro (`^major.minor`)
- [ ] `tech-stack.md` atualizado
- [ ] CI valida instalação com versão fixada
- [ ] Commit: `[TASK-008] chore: fixar versão do @anthropic-ai/claude-code`
