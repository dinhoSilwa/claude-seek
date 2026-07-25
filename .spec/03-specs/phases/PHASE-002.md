# PHASE-002 — Correções de segurança

- **Epic:** EPIC-001
- **Objetivo:** Eliminar vetores de injeção e exposição de credenciais
- **Tasks:** TASK-002
- **Dependências:** PHASE-001 (recomendado, não bloqueante)
- **Status:** planned

## Entregável
`config.env` não permite execução de código arbitrário. shellcheck passa sem warnings.
