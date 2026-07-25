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
@test "orion sem API key exibe mensagem de erro"
@test "orion sem API key retorna exit code não-zero"

# Config
@test "orion config show executa sem erros"

# History
@test "orion history list executa sem erros"
@test "orion history clear executa sem erros"

# Validação de flags
@test "orion --model com valor inválido não trava"

# Shellcheck
@test "install-orion.sh passa no shellcheck"
@test "uninstall-orion.sh passa no shellcheck"
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
