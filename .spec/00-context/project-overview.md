# Project Overview

## Nome do projeto
Orion

## Objetivo
Camada unificada de acesso a múltiplos provedores de inteligência artificial. O Orion permite configurar, alternar e utilizar modelos de diferentes fornecedores (OpenAI, Anthropic, DeepSeek, OpenRouter, Kimi, GLM e outros) através de uma única interface CLI, fazendo chamadas de API diretas sem dependência de binários externos.

## Escopo

**Dentro do escopo:**
- CLI em Node.js + TypeScript com suporte a múltiplos provedores
- Camada de abstração (provider adapters) isolada por fornecedor
- Gerenciamento seguro de múltiplas API keys
- Roteamento inteligente com fallback entre modelos
- Registro de modelos disponíveis por provedor
- Compatibilidade com provedores OpenAI API standard
- Distribuição via npm (`npm install -g orion-code`)

**MVP providers:** DeepSeek, OpenAI, Anthropic, OpenRouter, Kimi (Moonshot AI), GLM

**Fora do escopo (v1):**
- Suporte nativo a Windows (sem WSL)
- Modelos locais (Ollama, LM Studio)
- Interface web ou gráfica

## Stakeholders
- **Autor:** Cláudio Silva (dinhoSilwa)
- **Usuários:** Desenvolvedores que querem usar Claude Code sem custos Anthropic
- **Provedor externo:** DeepSeek (API) + Anthropic (Claude Code CLI)

## Links
- Repositório: https://github.com/dinhoSilwa/orion
- npm: https://www.npmjs.com/package/orion
- DeepSeek API: https://platform.deepseek.com
- Claude Code: https://www.npmjs.com/package/@anthropic-ai/claude-code
