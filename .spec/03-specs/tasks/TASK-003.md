# TASK-003 — Verificar e corrigir nomes dos modelos DeepSeek

- **Epic:** EPIC-001
- **Phase:** PHASE-003
- **Tipo:** fix
- **Status:** planned

## Contexto
O fallback de modelos tenta `deepseek-v4-pro` → `deepseek-v4-flash` → `deepseek-chat`. Os nomes `deepseek-v4-pro` e `deepseek-v4-flash` provavelmente não existem na API DeepSeek atual — a documentação oficial usa `deepseek-chat` e `deepseek-reasoner`. Como o `select_model` chama a API para testar cada modelo, ele sempre cai no `deepseek-chat`, mas exibe o nome errado no banner.

## Descrição
1. Verificar na documentação oficial da DeepSeek quais modelos estão disponíveis via endpoint `/anthropic/v1/messages`
2. Atualizar a lista de fallback com nomes corretos
3. Atualizar README.md com os nomes reais
4. Atualizar `cmd_help` e mensagens de output

**Modelos a verificar (documentação DeepSeek):**
- `deepseek-chat` — modelo base de chat (confirmado)
- `deepseek-reasoner` — modelo de raciocínio
- `deepseek-v3` — possível alias de `deepseek-chat`
- `deepseek-v4-pro` / `deepseek-v4-flash` — verificar existência real

## Arquivos relevantes
- `install-orion.sh` — função `select_model` (linha ~189) e lista de modelos (linha ~205)
- `README.md` — seção Features e tabela de comandos

## Definition of Ready
- [x] Spec completa
- [ ] Documentação oficial DeepSeek consultada para confirmar nomes

## Definition of Done
- [ ] Nomes de modelos no fallback são reais e funcionais
- [ ] README atualizado com modelos corretos
- [ ] `orion doctor` exibe status real dos modelos
- [ ] Commit: `[TASK-003] fix: corrigir nomes dos modelos DeepSeek`
