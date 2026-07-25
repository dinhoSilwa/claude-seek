# TASK-010 — Adicionar CHANGELOG.md

- **Epic:** EPIC-003
- **Phase:** PHASE-006
- **Tipo:** docs
- **Status:** planned

## Contexto
Não existe `CHANGELOG.md`. Usuários não sabem o que mudou entre versões, e o histórico de commits não tem padrão suficiente para gerar changelog automaticamente.

## Descrição
Criar `CHANGELOG.md` seguindo o formato [Keep a Changelog](https://keepachangelog.com) e reconstruir entradas a partir do histórico de commits.

**Formato:**
```markdown
# Changelog

## [Unreleased]

## [1.3.0] - YYYY-MM-DD
### Added
### Fixed
### Changed

## [1.0.1] - YYYY-MM-DD
...
```

## Arquivos relevantes
- `CHANGELOG.md` — criar na raiz
- `scripts/release.sh` (TASK-009) — deve atualizar CHANGELOG automaticamente

## Definition of Done
- [ ] `CHANGELOG.md` criado com histórico desde v1.0.0
- [ ] Formato Keep a Changelog
- [ ] Mencionado no README
- [ ] Commit: `[TASK-010] docs: adicionar CHANGELOG.md`
