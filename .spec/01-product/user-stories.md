# User Stories

---

### US-001 — Instalar e usar pela primeira vez
- **Como** desenvolvedor com Node.js instalado
- **Quero** instalar o orion via npm e começar a usá-lo
- **Para** ter um assistente de código gratuito sem configuração complexa
- **Critérios de aceite:**
  - [ ] `npm install -g orion` completa sem erros
  - [ ] `orion setup` guia pelo processo de configuração
  - [ ] `orion` inicia uma sessão interativa após setup

---

### US-002 — Configurar API key com segurança
- **Como** desenvolvedor
- **Quero** salvar minha API key DeepSeek de forma segura
- **Para** não precisar digitá-la a cada uso e não expô-la acidentalmente
- **Critérios de aceite:**
  - [ ] Key salva em `~/.orion/key` com chmod 600
  - [ ] Key nunca aparece em logs ou output do terminal
  - [ ] `DEEPSEEK_API_KEY` no ambiente tem prioridade sobre arquivo salvo

---

### US-003 — Usar modelo específico
- **Como** desenvolvedor
- **Quero** forçar o uso de um modelo específico
- **Para** controlar qualidade vs velocidade da resposta
- **Critérios de aceite:**
  - [ ] `orion --model flash` usa deepseek-v4-flash
  - [ ] `orion --model pro` usa deepseek-v4-pro
  - [ ] Modelo inválido exibe mensagem de erro clara

---

### US-004 — Diagnosticar problemas
- **Como** desenvolvedor com problema na ferramenta
- **Quero** executar um diagnóstico
- **Para** entender o que está errado sem depurar manualmente
- **Critérios de aceite:**
  - [ ] `orion doctor` exibe versão do Node.js e npm
  - [ ] Exibe status da API key (configurada / inválida / ausente)
  - [ ] Exibe disponibilidade de cada modelo
  - [ ] Exibe número de sessões no histórico

---

### US-005 — Consultar histórico de sessões
- **Como** desenvolvedor
- **Quero** ver o histórico das minhas sessões anteriores
- **Para** rastrear quando e em qual projeto usei a ferramenta
- **Critérios de aceite:**
  - [ ] `orion history list` exibe sessões com ID, data e modelo
  - [ ] `orion history show <id>` exibe detalhes da sessão
  - [ ] `orion history clear` remove todo o histórico

---

### US-006 — Executar query pontual sem sessão interativa
- **Como** desenvolvedor em script ou CI
- **Quero** passar uma query diretamente pela linha de comando
- **Para** integrar o assistente em automações
- **Critérios de aceite:**
  - [ ] `orion -p "query"` executa e encerra
  - [ ] Exit code 0 em sucesso, não-zero em erro
