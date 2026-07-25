# TASK-001 — Sincronizar versão entre package.json e install script

- **Epic:** EPIC-001
- **Phase:** PHASE-001
- **Tipo:** fix
- **Status:** planned

## Contexto
`package.json` declara `1.0.2` enquanto `install-orion.sh` instala e reporta `v1.3.0`. Usuários que instalam via npm recebem um wrapper que se auto-instala como uma versão diferente, causando confusão no `--version` e no npm registry.

## Descrição
Tornar `package.json` a única fonte de verdade para a versão. O `install-orion.sh` deve ler a versão dinamicamente em vez de ter ela hardcoded.

**Abordagem sugerida:**
- No `install-orion.sh`, substituir versão hardcoded por leitura via `node -p "require('./package.json').version"` (quando disponível) ou manter constante sincronizada manualmente com um script de release
- Atualizar `package.json` para a versão real atual (`1.3.0`)
- Atualizar todas as ocorrências de versão no install script para usar a variável

## Arquivos relevantes
- `package.json` — linha 3 (`"version": "1.0.2"`)
- `install-orion.sh` — linhas 18, 49, 67, 447, 502, 578 (todas com `1.3.0` hardcoded)

## Definition of Ready
- [x] Spec completa
- [x] Dependências claras
- [x] Sem dependência de API externa

## Definition of Done
- [ ] `package.json` versão == versão reportada em `--version`
- [ ] `package.json` versão == versão exibida no banner de instalação
- [ ] `npm version patch/minor/major` propaga corretamente
- [ ] Testes passam
- [ ] Commit: `[TASK-001] fix: sincronizar versão entre package.json e install script`
