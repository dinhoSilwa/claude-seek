# Requirements

## Funcionais

| ID | Requisito | Prioridade | Status |
|----|-----------|------------|--------|
| RF-001 | Instalar via npm/yarn global | Must Have | done |
| RF-002 | Wizard interativo de setup | Must Have | done |
| RF-003 | Validar API key durante setup | Must Have | done |
| RF-004 | Fallback automático de modelos | Must Have | done |
| RF-005 | Flag `--model` para forçar modelo | Should Have | done |
| RF-006 | Query direta via `-p "query"` | Should Have | done |
| RF-007 | Histórico de sessões (list/show/clear) | Should Have | done |
| RF-008 | Health check `doctor` | Should Have | done |
| RF-009 | Gerenciamento de API key via config | Must Have | done |
| RF-010 | Script de desinstalação | Must Have | done |
| RF-011 | Comando `update` para atualizar versão | Nice to Have | pending |

## Não-Funcionais

| ID | Requisito | Categoria | Meta | Status |
|----|-----------|-----------|------|--------|
| RNF-001 | Startup < 3s (uso subsequente) | Performance | 3s | done |
| RNF-002 | API key com permissão 600 | Segurança | chmod 600 | done |
| RNF-003 | API key nunca em logs/output | Segurança | zero exposure | done |
| RNF-004 | Suporte Linux e macOS | Compatibilidade | bash POSIX | done |
| RNF-005 | Node.js 18+ | Compatibilidade | node -v >= 18 | done |
| RNF-006 | Versões sincronizadas (package.json x install script) | Manutenibilidade | única fonte de verdade | pending |
| RNF-007 | `source config.env` sem execução arbitrária | Segurança | parsing seguro | pending |
