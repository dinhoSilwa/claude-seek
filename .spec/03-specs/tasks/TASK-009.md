# TASK-009 — Criar script de release automatizado

- **Epic:** EPIC-003
- **Phase:** PHASE-006
- **Tipo:** chore
- **Status:** planned

## Contexto
Atualmente a versão está espalhada em múltiplos lugares (`package.json`, `install-claude-seek.sh` em várias linhas). Um release manual esquece de atualizar algum, gerando inconsistências como a atual (1.0.2 vs 1.3.0).

## Descrição
Criar `scripts/release.sh` que automatiza o bump de versão e garante consistência.

**Interface:**
```bash
./scripts/release.sh patch   # 1.0.2 → 1.0.3
./scripts/release.sh minor   # 1.0.2 → 1.1.0
./scripts/release.sh major   # 1.0.2 → 2.0.0
```

**O script deve:**
1. Ler versão atual de `package.json`
2. Calcular nova versão
3. Atualizar `package.json` via `npm version` (sem criar tag ainda)
4. Atualizar todas as ocorrências de versão em `install-claude-seek.sh` via `sed`
5. Atualizar `CHANGELOG.md` com a nova entrada
6. Criar commit: `chore: release vX.Y.Z`
7. Criar tag git: `vX.Y.Z`
8. Exibir próximos passos: `git push && git push --tags && npm publish`

## Arquivos relevantes
- `scripts/` — criar `release.sh`
- `package.json`
- `install-claude-seek.sh`
- `CHANGELOG.md` (depende de TASK-010)

## Definition of Done
- [ ] `./scripts/release.sh patch` atualiza todos os arquivos corretamente
- [ ] Versão resultante é consistente em todos os lugares
- [ ] Script é idempotente (pode rodar novamente sem efeitos colaterais)
- [ ] `chmod +x scripts/release.sh`
- [ ] Commit: `[TASK-009] chore: criar script de release automatizado`
