# TASK-004 — Expandir cobertura de testes bats

- **Epic:** EPIC-001
- **Phase:** PHASE-003
- **Tipo:** chore
- **Status:** planned

## Contexto
`tests/test_basic.bats` só verifica existência de arquivos e se `--help`/`--version` retornam exit 0. Não cobre: chave inválida, fallback de modelo, comandos de config, histórico, ou comportamento sem API key. A cobertura atual não detectaria regressões funcionais.

## Descrição
Expandir a suíte de testes com casos que não dependam de API key real (usar mock ou variável de ambiente de teste).

**Novos testes a adicionar:**

```bash
# Sem API key configurada
@test "claude-seek sem API key exibe mensagem de erro"
@test "claude-seek sem API key retorna exit code não-zero"

# Config
@test "claude-seek config show executa sem erros"

# History
@test "claude-seek history list executa sem erros"
@test "claude-seek history clear executa sem erros"

# Validação de flags
@test "claude-seek --model com valor inválido não trava"

# Shellcheck
@test "install-claude-seek.sh passa no shellcheck"
@test "uninstall-claude-seek.sh passa no shellcheck"
```

## Arquivos relevantes
- `tests/test_basic.bats` — arquivo a expandir
- `tests/test_history.bats.sh` — verificar se deve ser convertido para `.bats`

## Definition of Ready
- [x] Spec completa
- [x] bats disponível no CI (Ubuntu/macOS)

## Definition of Done
- [ ] Mínimo 8 novos testes adicionados
- [ ] `test_history.bats.sh` convertido para `.bats` ou removido
- [ ] Todos os testes passam no CI (Ubuntu + macOS)
- [ ] Commit: `[TASK-004] chore: expandir cobertura de testes bats`
