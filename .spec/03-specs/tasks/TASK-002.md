# TASK-002 — Substituir `source config.env` por parsing seguro

- **Epic:** EPIC-001
- **Phase:** PHASE-002
- **Tipo:** fix
- **Status:** planned

## Contexto
O wrapper gerado pelo `install-claude-seek.sh` executa `source "$CONFIG_FILE"` (linha 114 do script gerado). Isso significa que qualquer conteúdo em `~/.claude-seek/config.env` é executado como código Bash. Se um atacante conseguir escrever nesse arquivo, obtém execução de código no contexto do usuário.

## Descrição
Substituir `source "$CONFIG_FILE"` por leitura segura variável a variável usando `grep`.

**Implementação:**
```bash
# Em vez de:
source "$CONFIG_FILE"

# Usar:
HISTORY_ENABLED=$(grep '^HISTORY_ENABLED=' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
DEFAULT_MODEL=$(grep '^DEFAULT_MODEL=' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
SESSION_TIMEOUT_HOURS=$(grep '^SESSION_TIMEOUT_HOURS=' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
NO_COLOR=$(grep '^NO_COLOR=' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
LOG_LEVEL=$(grep '^LOG_LEVEL=' "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '[:space:]')
```

Manter valores default caso a variável esteja ausente no arquivo.

## Arquivos relevantes
- `install-claude-seek.sh` — bloco que gera o wrapper (a partir da linha 64), seção "Load user config" dentro do heredoc `WRAPPEREOF`

## Definition of Ready
- [x] Spec completa
- [x] Abordagem definida

## Definition of Done
- [ ] `source "$CONFIG_FILE"` removido do wrapper gerado
- [ ] Parsing seguro implementado para as 5 variáveis de config
- [ ] Valores default mantidos quando variável ausente
- [ ] shellcheck passa sem warnings
- [ ] Commit: `[TASK-002] fix: substituir source config.env por parsing seguro`
