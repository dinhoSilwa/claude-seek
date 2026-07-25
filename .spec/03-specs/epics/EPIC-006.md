# EPIC-006 — Gerenciamento de API Keys

- **Objetivo:** Armazenamento seguro e gerenciamento de credenciais de múltiplos providers
- **Status:** planned
- **Depende de:** EPIC-005

## Tasks
- [ ] TASK-017 — Implementar config store (arquivo criptografado em ~/.orion/)
- [ ] TASK-018 — Comandos: `orion config set-key <provider>`, `unset-key`, `show`
- [ ] TASK-019 — Ativação/desativação de credenciais por provider
- [ ] TASK-020 — Garantir que keys nunca aparecem em logs ou output

## Critérios de conclusão
- Keys armazenadas com proteção (chmod 600 mínimo, criptografia opcional)
- `orion config show` não exibe key completa (apenas últimos 4 chars)
- Testes cobrem leitura/escrita/remoção de keys
