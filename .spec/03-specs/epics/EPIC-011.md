# EPIC-011 — Proxy Local Anthropic↔OpenAI

- **Objetivo:** Permitir que qualquer provider OpenAI-compatible funcione com Claude Code via proxy de tradução de protocolo
- **Status:** in-progress
- **Depende de:** EPIC-006, EPIC-007

## Problema

Claude Code usa o SDK da Anthropic (Anthropic Messages API format).
Providers como Kimi, GLM, OpenRouter e OpenAI usam OpenAI Chat Completions format.
São protocolos diferentes e incompatíveis diretamente.

## Solução

O Orion sobe um servidor HTTP local antes de lançar o `claude`, configurando:
- `ANTHROPIC_BASE_URL=http://127.0.0.1:<porta>`
- O proxy traduz Anthropic → OpenAI → Anthropic em tempo real

## Tasks

- [ ] TASK-037 — Tradução de formato request/response (Anthropic ↔ OpenAI)
- [ ] TASK-038 — Tradução de streaming SSE (Anthropic ↔ OpenAI)
- [ ] TASK-039 — Servidor HTTP proxy com roteamento por provider
- [ ] TASK-040 — Integração com CLI: proxy sobe antes do claude, desce junto
- [ ] TASK-041 — Tradução de tool calls DSML (DeepSeek) → Anthropic tool_use

## Status atual

- Proxy sobe corretamente ✓
- URL de upstream correta ✓  
- Non-streaming traduz certo (testado com mock, 16/16) ✓
- Resposta chega ao Claude Code (clipboard confirma) ✓
- **Claude Code não renderiza a resposta na UI** ✗ — bug aberto
- **Tool calls aparecem como texto cru com tags DSML** ✗ — bug aberto (TASK-041)

## Problema identificado

Claude Code recebe o stream (prova: copia chars pro clipboard) mas não exibe na tela.
Causa provável: evento SSE com campo/sequência incorreta para o Claude Code v2.x.
DeepSeek funciona pois tem endpoint Anthropic-nativo (sem proxy).

## TASK-041 — Tool calls DSML → Anthropic (DeepSeek)

**Observado em:** 2026-07-25, DeepSeek-v4-flash via proxy, Claude Code v2.1.179

DeepSeek retorna tool calls no formato DSML próprio:
```
<｜｜DSML｜｜tool_calls>
<｜｜DSML｜｜invoke name="Bash">
<｜｜DSML｜｜parameter name="command" string="true">...</｜｜DSML｜｜parameter>
</｜｜DSML｜｜invoke>
</｜｜DSML｜｜tool_calls>
```

O proxy não reconhece esse formato — passa como texto cru para o Claude Code, que exibe os tags na tela em vez de executar as ferramentas.

**Causa:** `translate.ts` converte OpenAI `tool_calls` JSON → Anthropic `tool_use` blocks, mas DeepSeek-v4 emite DSML em vez de JSON padrão OpenAI.

**Fix necessário em `src/proxy/translate.ts`:**
1. Detectar presença de `<｜｜DSML｜｜tool_calls>` no content do assistant
2. Parsear os blocos DSML para extrair `name` e `parameters`
3. Converter para Anthropic `tool_use` content blocks
4. Remover os tags DSML do texto restante

**Alternativa:** Verificar se DeepSeek API aceita `tool_choice: "auto"` com tools no request e retorna JSON padrão — pode eliminar o DSML.

## Próximos passos para resolver

### Path A — Estudar código do 9Router (recomendado)
- Repo público: github.com/decolua/9router
- Localizar: `src/` → tradução SSE OpenAI → Anthropic
- Comparar com `src/proxy/stream.ts` e corrigir diferenças

### Path B — Interceptar stream real
- Rodar 9Router localmente
- Logar os eventos SSE exatos que ele manda pro Claude Code
- Comparar com o que nosso proxy manda (ORION_DEBUG=1)
- A diferença byte-a-byte é o bug

### Path C — Ler SDK Anthropic
- SDK TypeScript open source
- Ver quais campos disparam render na UI do Claude Code

## Critérios de conclusão

- `orion` com Kimi/OpenAI/GLM abre Claude Code e responde com texto visível
- Streaming aparece progressivamente (não só no clipboard)
- Proxy para quando o claude fecha
- Providers nativos (Anthropic) não passam pelo proxy
