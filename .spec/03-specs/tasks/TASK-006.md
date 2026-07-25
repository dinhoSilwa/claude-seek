# TASK-006 — Feedback visual durante seleção de modelo

- **Epic:** EPIC-002
- **Phase:** PHASE-005
- **Tipo:** feature
- **Status:** planned

## Contexto
`select_model` faz até 4 chamadas HTTP sequenciais para testar modelos (1 para o default + 3 no fallback). Durante esse tempo o terminal fica silencioso por vários segundos, o que parece um travamento para o usuário.

## Descrição
Exibir progresso durante a seleção de modelo com indicação do que está sendo testado.

**Comportamento atual:**
```
🚀 Starting orion with model: deepseek-chat
```
(depois de 5-10s de silêncio)

**Comportamento esperado:**
```
Selecting model...
  → Testing deepseek-v4-pro... unavailable
  → Testing deepseek-v4-flash... unavailable  
  → Testing deepseek-chat... available
🚀 Starting orion with model: deepseek-chat
```

Usar `\r` para sobrescrever a linha em vez de imprimir múltiplas linhas se preferir output limpo.

## Arquivos relevantes
- `install-orion.sh` — função `select_model` (~linha 189) dentro do heredoc

## Definition of Done
- [ ] Usuário vê progresso durante seleção de modelo
- [ ] Output compatível com `NO_COLOR=true`
- [ ] Não quebra output quando não é TTY (pipes, CI)
- [ ] Commit: `[TASK-006] feat: feedback visual durante seleção de modelo`
