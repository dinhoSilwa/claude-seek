# SDD Engineering System

## VISÃO GERAL

Sistema de desenvolvimento baseado em **Spec Driven Development (SDD)** com DDD, observabilidade, segurança e automação com IA.

Toda especificação vive em `.spec/` na raiz do projeto. É a fonte de verdade antes de qualquer implementação.

---

## BOOTSTRAP OBRIGATÓRIO

Se `.spec/` não existir no projeto, crie a estrutura completa antes de qualquer ação:

```
.spec/
├── 00-context/
│   ├── project-overview.md
│   ├── tech-stack.md
│   └── decision-log.md
├── 01-product/
│   ├── prd.md
│   ├── user-stories.md
│   └── requirements.md
├── 02-domain/
│   ├── entities.md
│   ├── aggregates.md
│   ├── events.md
│   └── bounded-contexts.md
├── 03-specs/
│   ├── epics/
│   ├── phases/
│   └── tasks/
├── 04-architecture/
│   ├── frontend.md
│   ├── backend.md
│   ├── api-contracts.md
│   └── diagrams/
├── 05-quality/
│   └── test-strategy.md
├── 06-observability/
│   └── strategy.md
├── 07-infra/
│   └── deploy.md
└── 99-templates/
    ├── task.md
    ├── epic.md
    └── adr.md
```

---

## FASES OBRIGATÓRIAS (SDD FLOW)

### FASE 0 — CONTEXTO
- `.spec/00-context/project-overview.md`
- `.spec/00-context/tech-stack.md`
- `.spec/00-context/decision-log.md`

### FASE 1 — PRODUTO
- PRD, user stories, requisitos funcionais e não funcionais
- Caminho: `.spec/01-product/`

### FASE 2 — DOMAIN MODEL
- Entidades, value objects, aggregates, eventos de domínio, bounded contexts
- Caminho: `.spec/02-domain/`

### FASE 3 — ESPECIFICAÇÃO
- Epics, phases, tasks, RFCs
- Caminho: `.spec/03-specs/`

### FASE 4 — ARQUITETURA
- Frontend architecture, backend architecture, API contracts, data design, diagramas
- Caminho: `.spec/04-architecture/`

### FASE 5 — IMPLEMENTAÇÃO
- Execução baseada em tasks com rastreabilidade obrigatória e commits estruturados

### FASE 6 — QUALIDADE
- Testes, bugs, performance, acessibilidade, segurança
- Caminho: `.spec/05-quality/`

### FASE 7 — OBSERVABILIDADE
- Logs, métricas, tracing, alertas
- Caminho: `.spec/06-observability/`

### FASE 8 — INFRAESTRUTURA
- Deploy, CI/CD, rollback, ambientes
- Caminho: `.spec/07-infra/`

---

## REGRAS OBRIGATÓRIAS DE EXECUÇÃO

### 1. NUNCA implementar sem especificação
Toda implementação deve referenciar uma task, phase ou epic existente em `.spec/03-specs/`.

### 2. SEMPRE validar contexto antes de codar
Antes de qualquer mudança, ler:
- `.spec/00-context/` — visão geral e stack
- `.spec/03-specs/tasks/` — task atual
- `.spec/04-architecture/` — arquitetura relevante
- `.spec/00-context/decision-log.md` — ADRs
- Código existente no projeto

### 3. SEMPRE usar terminal para operações
Preferir CLI para: instalação de dependências, build, testes, migrations, lint, format.

### 4. TOOLING AGNÓSTICO — detectar antes de assumir

**Lint:** Ruff, ESLint, Clippy, golangci-lint  
**Formatter:** Black, Prettier, rustfmt, gofmt  

Verificar `package.json`, `pyproject.toml`, `Cargo.toml` ou equivalente antes de executar qualquer ferramenta.

### 5. QUALIDADE OBRIGATÓRIA
Nenhuma task finalizada sem:
- lint OK
- build OK
- testes OK
- formatter aplicado
- docs em `.spec/` atualizados

### 6. RASTREABILIDADE RESTRITA
Adicionar anotação `@spec` apenas em:
- Arquivos de domínio (entities, aggregates, events)
- API contracts
- Módulos de segurança e auth

```ts
/**
 * @spec: TASK-ID
 * @epic: EPIC-ID
 */
```

Não aplicar em componentes de UI, utilitários, configs ou infraestrutura.

### 7. COMMIT PADRÃO
```
[TASK-ID] tipo: descrição curta
```

Commitar ao final de cada task concluída (não por arquivo, não por fase inteira).

### 8. NUNCA INVENTAR CONTEXTO
Proibido inventar: APIs, schemas, endpoints, dependências.  
Sempre validar código existente antes de qualquer suposição.

### 9. PREFERIR AUTOMAÇÃO
Usar generators, scaffolds, scripts, task runners e CI/CD sempre que disponíveis.

---

## DEFINITIONS

### Definition of Ready
- Spec completa em `.spec/03-specs/tasks/`
- Dependências claras
- API definida em `.spec/04-architecture/api-contracts.md`

### Definition of Done
- Código implementado
- Testes OK
- Lint OK
- Docs em `.spec/` atualizados
- Commit com TASK-ID
