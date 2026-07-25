# Decision Log (ADRs)

---

### ADR-001 — Usar variáveis de ambiente para substituir provedor do Claude Code
- **Data:** 2025-07-01 (estimado, baseado no histórico de commits)
- **Status:** accepted

**Contexto:** Era necessário redirecionar o Claude Code para a API DeepSeek sem forkar ou modificar o pacote `@anthropic-ai/claude-code`.

**Decisão:** Usar `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN` e `ANTHROPIC_MODEL` para injetar o provedor DeepSeek antes de chamar `exec claude`.

**Consequências:**
- (+) Zero modificação no Claude Code — apenas configuração de ambiente
- (+) Compatível com qualquer versão futura do Claude Code que honre essas variáveis
- (-) Depende de comportamento não documentado do Claude Code (pode quebrar em versões futuras)
- (-) Modelos DeepSeek devem ser compatíveis com a API de mensagens Anthropic

---

### ADR-002 — Instalação self-contained em `~/.orion/`
- **Data:** 2025-07-01 (estimado)
- **Status:** accepted

**Contexto:** O pacote npm precisa instalar `@anthropic-ai/claude-code` em runtime, não como dependência declarada, pois o tamanho seria proibitivo para o pacote npm.

**Decisão:** O `bin/orion` (wrapper) detecta se `~/.orion/` existe. Se não, executa `install-orion.sh` que cria o diretório, inicializa um `package.json` local e roda `npm install @anthropic-ai/claude-code`.

**Consequências:**
- (+) Pacote npm leve (sem bundling do Claude Code)
- (+) Atualização independente do Claude Code
- (-) Primeiro uso requer conexão à internet e tempo de instalação
- (-) Cria estado fora do projeto (`~/`) que precisa de `uninstall-orion.sh` para limpeza

---

### ADR-003 — API key salva em arquivo com chmod 600
- **Data:** 2025-07-01 (estimado)
- **Status:** accepted

**Contexto:** A chave DeepSeek precisa persistir entre sessões sem expor ao ambiente global.

**Decisão:** Salvar em `~/.orion/key` com permissões `600` (leitura apenas pelo dono). Suporte adicional via variável de ambiente `DEEPSEEK_API_KEY` com prioridade maior.

**Consequências:**
- (+) Chave não fica em variáveis de ambiente globais ou `.bashrc`
- (+) `DEEPSEEK_API_KEY` no ambiente permite uso em CI/CD
- (-) `source config.env` no wrapper gera risco de execução de código arbitrário se o arquivo for comprometido

---

### ADR-004 — Distribuição via npm sem dependências de produção declaradas
- **Data:** 2025-07-01 (estimado)
- **Status:** accepted

**Contexto:** `@anthropic-ai/claude-code` é pesado. Declará-lo como dependência npm tornaria `npm install -g orion` lento.

**Decisão:** `package.json` não declara `dependencies`. A instalação real acontece em runtime via `install-orion.sh`.

**Consequências:**
- (+) `npm install -g orion` é instantâneo
- (-) Usuário só descobre a dependência Node.js/npm no primeiro uso
- (-) Versão do `@anthropic-ai/claude-code` não é fixada (always latest)

---

### ADR-005 — Inconsistência de versão entre package.json e install script (problema em aberto)
- **Data:** 2025-07-25
- **Status:** proposed (pendente resolução)

**Contexto:** `package.json` declara versão `1.0.2` enquanto `install-orion.sh` instala e reporta `v1.3.0`. Causa confusão para usuários e para o npm.

**Decisão:** Pendente — sincronizar versões usando `package.json` como única fonte de verdade.

**Alternativas a considerar:**
- Ler versão do `package.json` dentro do install script via `node -p "require('./package.json').version"`
- Adotar script de release que atualiza ambos os arquivos
