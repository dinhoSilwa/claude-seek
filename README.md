<div align="center">
  <img src="assets/cover.png" width="800"/>
</div>

---

# Orion

**AI coding assistant with multi-model support**

[![npm version](https://img.shields.io/npm/v/%40orion-ai%2Fcli.svg)](https://www.npmjs.com/package/@orion-ai/cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI Tests](https://github.com/dinhoSilwa/claude-seek/actions/workflows/test.yml/badge.svg)](https://github.com/dinhoSilwa/claude-seek/actions/workflows/test.yml)
[![npm downloads](https://img.shields.io/npm/dm/%40orion-ai%2Fcli.svg)](https://www.npmjs.com/package/@orion-ai/cli)

---

## Features

- DeepSeek V4 Pro - Best quality models for complex coding tasks
- Automatic fallback - Seamless fallback: Pro -> Flash
- Session history - Track all your conversations and sessions
- One-command setup - Interactive wizard for effortless configuration
- Health check - Built-in diagnostic tool
- 100% free - No credit card required

---

## Quick Install

### npm (recommended)
```bash
npm install -g @orion-ai/cli
orion setup
orion
```

### yarn
```bash
yarn global add @orion-ai/cli
orion setup
orion
```

### git clone
```bash
git clone https://github.com/dinhoSilwa/claude-seek.git
cd claude-seek
chmod +x install-orion.sh
./install-orion.sh
orion setup
orion
```

---

## Prerequisites

- Node.js 18 or higher
- npm (comes with Node.js)
- DeepSeek API key - [Get one here](https://platform.deepseek.com/api_keys)

---

## Commands

| Command | Description |
|---------|-------------|
| `orion` | Start interactive coding session |
| `orion -p "query"` | Run single query and exit |
| `orion --model MODEL` | Force specific model (pro/flash) |
| `orion setup` | Interactive setup wizard |
| `orion config set-key` | Configure API key |
| `orion config unset-key` | Remove API key |
| `orion config show` | Show current settings |
| `orion history list` | List all sessions |
| `orion history show <id>` | Show session details |
| `orion history clear` | Clear all history |
| `orion doctor` | Health check and diagnostics |
| `orion update` | Update to latest version |
| `orion --version` | Show version |
| `orion --help` | Show help |

---

## Examples

### Interactive session
```bash
orion
```

Output:
```
Starting orion with model: deepseek-v4-pro

> Create a Python function that calculates Fibonacci
```

### Single query
```bash
orion -p "Explain React hooks in simple terms"
```

### Force specific model
```bash
orion --model flash -p "Quick: what's 2+2?"
```

### Health check
```bash
orion doctor
```

Output:
```
System:
   Node.js: v20.10.0
   npm: 10.2.3
   OS: Linux

API Key:
   Status: Configured
   Valid: Yes

History:
   Status: Enabled
   Sessions: 5

Models:
   deepseek-v4-pro: Available
   deepseek-v4-flash: Available
```

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DEEPSEEK_API_KEY` | Set API key directly (overrides saved key) |
| `NO_COLOR` | Disable colored output |
| `LOG_LEVEL` | Logging level (debug/info/warn/error) |

---

## File Structure

After installation:
```
~/.orion/
├── orion                    # Main executable
├── node_modules/            # Dependencies
├── key                      # API key (secure, 600 permissions)
├── config.env               # User configuration
├── history/                 # Session history
└── logs/                    # Debug logs
```

---

## Development

### Run tests
```bash
npm install -g bats
bats tests/
```

### Run shellcheck
```bash
shellcheck install-orion.sh uninstall-orion.sh
```

### Local installation
```bash
./install-orion.sh
```

### Uninstall
```bash
./uninstall-orion.sh
```

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## License

MIT © [Cláudio Silva](https://github.com/dinhoSilwa)

---

## Credits

- [DeepSeek](https://deepseek.com) - API provider
- [Anthropic](https://anthropic.com) - Claude Code

---

## Support

- Email: claudiosilva.one@gmail.com
- LinkedIn: [Cláudio Silva](https://www.linkedin.com/in/claudiosilva-dev)
- Issues: [GitHub Issues](https://github.com/dinhoSilwa/claude-seek/issues)
