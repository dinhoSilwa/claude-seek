# EPIC-001 — Estabilização e correção de bugs críticos

- **Objetivo:** Corrigir os problemas identificados na análise inicial que afetam confiabilidade, segurança e manutenibilidade
- **Status:** planned

## Fases
- [ ] PHASE-001 — Sincronização de versões
- [ ] PHASE-002 — Correções de segurança
- [ ] PHASE-003 — Validação de modelos DeepSeek

## Tasks
- [ ] TASK-001 — Sincronizar versão entre package.json e install script
- [ ] TASK-002 — Substituir `source config.env` por parsing seguro
- [ ] TASK-003 — Verificar e corrigir nomes dos modelos DeepSeek
- [ ] TASK-004 — Expandir cobertura de testes bats

## Critérios de conclusão
- `package.json` e `install-orion.sh` reportam a mesma versão
- `config.env` não permite execução de código arbitrário
- Modelos listados no fallback existem de fato na API DeepSeek
- Testes cobrem fluxos de chave inválida e fallback de modelo
