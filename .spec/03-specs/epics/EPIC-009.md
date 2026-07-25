# EPIC-009 — Sistema de Roteamento Inteligente

- **Objetivo:** Selecionar e alternar modelos automaticamente com base em regras e disponibilidade
- **Status:** planned
- **Depende de:** EPIC-007, EPIC-008

## Tasks
- [ ] TASK-030 — Regras de roteamento: custo, velocidade, capacidade, disponibilidade
- [ ] TASK-031 — Fallback automático entre providers ao detectar falha de API
- [ ] TASK-032 — Log de roteamento (qual provider/modelo foi usado e por quê)

## Critérios de conclusão
- Fallback funciona quando provider primário retorna erro
- Regras configuráveis por usuário em `~/.orion/config`
- Histórico de roteamento disponível em `orion history`
