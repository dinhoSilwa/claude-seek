# TASK-005 — Implementar comando `update`

- **Epic:** EPIC-002
- **Phase:** PHASE-004
- **Tipo:** feature
- **Status:** planned

## Contexto
O README documenta `orion update` mas o comando não existe no dispatch do script. Ao executar, cai no fluxo principal e tenta iniciar uma sessão.

## Descrição
Implementar `update` que re-executa `npm install @anthropic-ai/claude-code` no diretório `~/.orion/` para atualizar o Claude Code, e opcionalmente baixa a versão mais recente do próprio orion via npm.

**Fluxo sugerido:**
```bash
orion update
  → echo "Checking for updates..."
  → cd ~/.orion && npm install @anthropic-ai/claude-code@latest
  → echo "✓ @anthropic-ai/claude-code updated to $(node -p "require('./node_modules/@anthropic-ai/claude-code/package.json').version")"
  → npm install -g orion@latest  # atualiza o próprio wrapper
  → echo "✓ orion updated"
```

## Arquivos relevantes
- `install-orion.sh` — bloco `case "${1:-}"` no dispatch (linha ~482), dentro do heredoc `WRAPPEREOF`

## Definition of Done
- [ ] `orion update` executa sem erro
- [ ] Atualiza `@anthropic-ai/claude-code` para latest
- [ ] Exibe versão instalada após update
- [ ] Adicionado ao `cmd_help`
- [ ] Testes: `orion update --dry-run` ou mock
- [ ] Commit: `[TASK-005] feat: implementar comando update`
