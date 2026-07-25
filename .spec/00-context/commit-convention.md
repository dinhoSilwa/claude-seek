# Commit Convention

## Formato

```
[TASK-ID] type(scope): description
```

Para commits sem task associada (infra, docs de setup, etc.):

```
type(scope): description
```

## Tipos

| Tipo | Quando usar |
|------|-------------|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug ou comportamento incorreto |
| `test` | Adição ou correção de testes |
| `docs` | Documentação (README, .spec, comentários) |
| `chore` | Tarefas de manutenção sem impacto no usuário |
| `refactor` | Refatoração sem mudança de comportamento |
| `ci` | Mudanças no pipeline de CI/CD |
| `style` | Formatação, espaços, sem lógica alterada |

## Escopos comuns

| Escopo | Área |
|--------|------|
| `install` | install-claude-seek.sh |
| `wrapper` | wrapper gerado em ~/.claude-seek |
| `config` | gerenciamento de configuração |
| `models` | seleção e fallback de modelos |
| `history` | histórico de sessões |
| `tests` | suíte de testes bats |
| `spec` | arquivos .spec/ |
| `readme` | README.md |
| `ci` | .github/workflows |

## Regras

- Descrição em português ou inglês, consistente por projeto
- Imperativo: "add", "fix", "remove" — não "added", "fixed"
- Sem ponto final
- Máximo 72 caracteres na linha de assunto
- Commitar ao final de cada task (não por arquivo, não por fase inteira)

## Exemplos

```
[TASK-001] fix(install): sync version to single source of truth
[TASK-002] fix(config): replace source with safe env parsing
[TASK-003] fix(models): remove deprecated deepseek-chat
[TASK-004] test(tests): expand bats coverage to 38 tests
docs(spec): add SDD engineering system and .spec scaffold
```
