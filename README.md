# claude-seek

**Claude Code with DeepSeek models - Free AI coding assistant**

[![npm version](https://img.shields.io/npm/v/claude-seek.svg)](https://www.npmjs.com/package/claude-seek)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI Tests](https://github.com/dinhoSilwa/claude-seek/actions/workflows/test.yml/badge.svg)](https://github.com/dinhoSilwa/claude-seek/actions/workflows/test.yml)
[![npm downloads](https://img.shields.io/npm/dm/claude-seek.svg)](https://www.npmjs.com/package/claude-seek)

---

## Features

- DeepSeek V4 Pro - Best quality models for complex coding tasks
- Automatic fallback - Seamless fallback: Pro -> Flash -> Chat
- Session history - Track all your conversations and sessions
- One-command setup - Interactive wizard for effortless configuration
- Health check - Built-in diagnostic tool
- 100% free - No credit card required

---

## Quick Install

### npm (recommended)
```bash
npm install -g claude-seek
claude-seek setup
claude-seek
```

### yarn
```bash
yarn global add claude-seek
claude-seek setup
claude-seek
```

### git clone
```bash
git clone https://github.com/dinhoSilwa/claude-seek.git
cd claude-seek
chmod +x install-claude-seek.sh
./install-claude-seek.sh
claude-seek setup
claude-seek
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
| `claude-seek` | Start interactive coding session |
| `claude-seek -p "query"` | Run single query and exit |
| `claude-seek --model MODEL` | Force specific model (pro/flash/chat) |
| `claude-seek setup` | Interactive setup wizard |
| `claude-seek config set-key` | Configure API key |
| `claude-seek config unset-key` | Remove API key |
| `claude-seek config show` | Show current settings |
| `claude-seek history list` | List all sessions |
| `claude-seek history show <id>` | Show session details |
| `claude-seek history clear` | Clear all history |
| `claude-seek doctor` | Health check and diagnostics |
| `claude-seek update` | Update to latest version |
| `claude-seek --version` | Show version |
| `claude-seek --help` | Show help |

---

## Examples

### Interactive session
```bash
claude-seek
```

Output:
```
Starting claude-seek with model: deepseek-v4-pro

> Create a Python function that calculates Fibonacci
```

### Single query
```bash
claude-seek -p "Explain React hooks in simple terms"
```

### Force specific model
```bash
claude-seek --model flash -p "Quick: what's 2+2?"
```

### Health check
```bash
claude-seek doctor
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
   deepseek-chat: Available
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
~/.claude-seek/
├── claude-seek              # Main executable
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
shellcheck install-claude-seek.sh uninstall-claude-seek.sh
```

### Local installation
```bash
./install-claude-seek.sh
```

### Uninstall
```bash
./uninstall-claude-seek.sh
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
