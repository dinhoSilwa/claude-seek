# Project Overview

## Nome do projeto
claude-seek

## Objetivo
Permitir o uso do **Claude Code** (CLI da Anthropic) com modelos da **DeepSeek** gratuitamente, redirecionando as variáveis de ambiente `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN` e `ANTHROPIC_MODEL` para a API compatível com Anthropic da DeepSeek.

O usuário obtém um assistente de código com interface familiar do Claude Code, sem custos de API Anthropic.

## Escopo

**Dentro do escopo:**
- CLI de instalação e configuração (setup wizard)
- Gerenciamento de API key da DeepSeek
- Seleção e fallback automático de modelos
- Histórico de sessões
- Health check (`doctor`)
- Distribuição via npm e git clone
- Suporte a Unix/macOS (Linux, macOS)

**Fora do escopo:**
- Suporte nativo a Windows (sem WSL/Git Bash)
- Implementação própria de chat/LLM
- Múltiplos provedores (apenas DeepSeek)

## Stakeholders
- **Autor:** Cláudio Silva (dinhoSilwa)
- **Usuários:** Desenvolvedores que querem usar Claude Code sem custos Anthropic
- **Provedor externo:** DeepSeek (API) + Anthropic (Claude Code CLI)

## Links
- Repositório: https://github.com/dinhoSilwa/claude-seek
- npm: https://www.npmjs.com/package/claude-seek
- DeepSeek API: https://platform.deepseek.com
- Claude Code: https://www.npmjs.com/package/@anthropic-ai/claude-code
