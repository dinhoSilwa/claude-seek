# Test Strategy

## Stack de testes
- **Framework:** bats (Bash Automated Testing System)
- **Lint:** shellcheck
- **CI:** GitHub Actions (Ubuntu + macOS)

## Cobertura atual

| Categoria | Testes existentes | Status |
|-----------|-------------------|--------|
| Existência de arquivos | 4 | ok |
| `--help` / `--version` | 2 | ok |
| `doctor` | 1 | ok |
| Fluxo sem API key | 0 | faltando |
| Config (set/show/unset) | 0 | faltando |
| Histórico | 0 | faltando |
| Fallback de modelo | 0 | faltando |
| shellcheck | 0 (só no CI) | mover para bats |

## Cobertura alvo (pós TASK-004)

Todo teste deve funcionar sem API key real. Usar `DEEPSEEK_API_KEY=invalid_test_key` para testar fluxos de erro.

### Testes que não precisam de API
- Existência de arquivos e scripts
- `--help`, `--version`
- `config show` (sem validação de key)
- `history list` (sem sessões)
- `history clear`
- Comportamento com key ausente (exit code + mensagem)
- shellcheck nos scripts

### Testes que precisam de mock/API real
- `validate_api_key` com key válida
- `select_model` com fallback
- `doctor` com key válida

> Para CI: esses testes devem ser condicionais a `DEEPSEEK_API_KEY` estar configurada como secret.

## Convenções
- Arquivos de teste: `tests/test_*.bats`
- `test_history.bats.sh` deve ser renomeado para `test_history.bats` (ver TASK-004)
- Cada teste deve ser independente (sem estado compartilhado entre testes)
