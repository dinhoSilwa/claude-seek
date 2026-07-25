# TASK-007 — Melhorar mensagens de erro

- **Epic:** EPIC-002
- **Phase:** PHASE-005
- **Tipo:** fix
- **Status:** planned

## Contexto
Mensagens de erro atuais informam o problema mas não indicam a ação corretiva. Exemplo: `✗ Error: Invalid API key` não diz o que o usuário deve fazer.

## Descrição
Padronizar todas as mensagens de erro para incluir: problema + causa provável + ação corretiva.

**Casos a melhorar:**

| Situação | Atual | Esperado |
|----------|-------|----------|
| API key ausente | `✗ Error: No API key found` | `✗ No API key found. Run: orion setup` |
| API key inválida | `✗ Error: Invalid API key` | `✗ Invalid API key. Check your key at platform.deepseek.com` |
| Nenhum modelo disponível | sem mensagem (usa fallback silencioso) | `⚠ All models unavailable. Check API status or your key` |
| Node.js ausente (install) | `❌ Node.js not found` | `❌ Node.js not found. Install from nodejs.org (v18+)` |
| npm ausente (install) | `❌ npm not found` | `❌ npm not found. Reinstall Node.js from nodejs.org` |

## Arquivos relevantes
- `install-orion.sh` — dentro do heredoc `WRAPPEREOF`, funções `cmd_*` e fluxo principal

## Definition of Done
- [ ] Todas as mensagens de erro listadas acima atualizadas
- [ ] Formato consistente: ícone + problema + ação
- [ ] shellcheck passa
- [ ] Commit: `[TASK-007] fix: melhorar mensagens de erro com ações corretivas`
