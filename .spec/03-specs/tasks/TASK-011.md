# TASK-011 — Investigar suporte Windows sem WSL

- **Epic:** EPIC-004
- **Phase:** PHASE-007
- **Tipo:** chore
- **Status:** planned

## Contexto
O CI testa no Windows mas apenas roda `bash install-orion.sh` via Git Bash e imprime "Installation completed" sem validar nada. O `bin/orion` é um script bash que não funciona nativamente no Windows sem Git Bash ou WSL. Usuários Windows que seguem o README pelo npm podem ficar presos.

## Descrição
Investigar as opções para suporte Windows real:

**Opção A — PowerShell wrapper**
Criar `bin/orion.cmd` ou `bin/orion.ps1` que executa a mesma lógica para Windows nativo.

**Opção B — WSL como requisito documentado**
Documentar explicitamente que Windows requer WSL2 ou Git Bash, com link de instalação.

**Opção C — Remover Windows do CI**
Se não há suporte real, remover Windows da matriz de CI para não dar falsa impressão de compatibilidade.

## Entregável desta task
Um relatório de decisão em `.spec/00-context/decision-log.md` (ADR-006) com a opção escolhida, bloqueando TASK-012.

## Definition of Done
- [ ] ADR-006 criado com decisão sobre suporte Windows
- [ ] TASK-012 atualizada com abordagem escolhida
- [ ] Commit: `[TASK-011] chore: ADR sobre suporte Windows`
