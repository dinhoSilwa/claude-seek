# PRD — orion

## Problema
Desenvolvedores querem usar o Claude Code (assistente de código da Anthropic) mas os custos de API Anthropic são uma barreira. A DeepSeek oferece modelos compatíveis com a API Anthropic a custo zero ou muito baixo, mas não existe uma ferramenta que conecte os dois sem configuração manual complexa.

## Objetivos
1. Permitir uso do Claude Code com modelos DeepSeek em menos de 5 minutos de setup
2. Não requerer modificações no Claude Code original
3. Suportar múltiplos modelos com fallback automático
4. Persistir configuração entre sessões com segurança

## Não-objetivos
- Implementar interface de chat própria
- Suportar outros provedores além de DeepSeek
- Suporte nativo a Windows (sem WSL/Git Bash)
- Fixar versão do Claude Code instalado

## Usuários-alvo
**Persona principal:** Desenvolvedor que conhece Claude Code, quer usá-lo gratuitamente e tem Node.js instalado.

**Persona secundária:** Desenvolvedor que quer avaliar modelos DeepSeek com interface familiar antes de pagar por Anthropic.

## Requisitos Funcionais
| ID | Requisito |
|----|-----------|
| RF-001 | Instalar via `npm install -g orion` |
| RF-002 | Wizard interativo de setup (`orion setup`) |
| RF-003 | Validar API key DeepSeek durante setup |
| RF-004 | Selecionar modelo automaticamente com fallback |
| RF-005 | Forçar modelo específico via `--model` |
| RF-006 | Executar query direta via `-p "query"` |
| RF-007 | Listar, visualizar e limpar histórico de sessões |
| RF-008 | Health check com diagnóstico (`orion doctor`) |
| RF-009 | Gerenciar API key (`config set-key`, `config unset-key`, `config show`) |
| RF-010 | Desinstalar completamente via `uninstall-orion.sh` |

## Requisitos Não-Funcionais
| ID | Requisito | Meta |
|----|-----------|------|
| RNF-001 | Tempo de instalação (primeiro uso) | < 60s em conexão normal |
| RNF-002 | Tempo de startup (uso subsequente) | < 3s |
| RNF-003 | Segurança da API key | chmod 600, nunca em logs |
| RNF-004 | Compatibilidade de SO | Linux, macOS |
| RNF-005 | Versão mínima Node.js | 18+ |

## Critérios de sucesso
- `npm install -g orion && orion setup && orion` funciona em menos de 5 minutos
- API key nunca aparece em logs ou output
- Fallback de modelo transparente para o usuário
