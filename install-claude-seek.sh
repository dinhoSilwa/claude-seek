#!/usr/bin/env bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

INSTALL_DIR="$HOME/.claude-seek"
WRAPPER_SCRIPT="claude-seek"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Installing claude-seek${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check Node.js
echo -e "${BLUE}📋 Checking prerequisites...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not found${NC}"
    echo -e "${YELLOW}   Install Node.js 18+ from https://nodejs.org/${NC}"
    exit 1
fi
echo -e "${GREEN}   ✅ Node.js $(node -v)${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm not found${NC}"
    exit 1
fi
echo -e "${GREEN}   ✅ npm $(npm -v)${NC}"
echo ""

# Create install directory
echo -e "${BLUE}📁 Creating installation directory...${NC}"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"
echo -e "${GREEN}   ✅ $INSTALL_DIR${NC}"

# Initialize npm project
if [ ! -f "package.json" ]; then
    echo -e "${BLUE}📦 Initializing npm project...${NC}"
    cat > package.json << 'EOF'
{
  "name": "claude-seek",
  "version": "1.0.0",
  "description": "Claude Code with DeepSeek models",
  "private": true
}
EOF
    echo -e "${GREEN}   ✅ package.json created${NC}"
fi

# Install dependency
echo -e "${BLUE}⬇️  Installing dependency...${NC}"
npm install @anthropic-ai/claude-code
echo -e "${GREEN}   ✅ Installation complete${NC}"
echo ""

# Create wrapper script (COMPLETELY REFACTORED)
echo -e "${BLUE}📝 Creating wrapper script...${NC}"
cat > "$INSTALL_DIR/$WRAPPER_SCRIPT" << 'EOF'
#!/bin/bash

# claude-seek - Claude Code with DeepSeek
# Version: 1.0.0

# Colors
if [ -z "${NO_COLOR:-}" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; NC=''
fi

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.claude-seek"
mkdir -p "$CONFIG_DIR"

# ============================================
# API KEY MANAGEMENT
# ============================================

get_api_key() {
    if [ -n "${DEEPSEEK_API_KEY:-}" ]; then
        echo "$DEEPSEEK_API_KEY"
        return 0
    fi
    if [ -f "$CONFIG_DIR/key" ]; then
        cat "$CONFIG_DIR/key"
        return 0
    fi
    return 1
}

save_api_key() {
    local key="$1"
    echo "$key" > "$CONFIG_DIR/key"
    chmod 600 "$CONFIG_DIR/key"
}

remove_api_key() {
    rm -f "$CONFIG_DIR/key"
}

# ============================================
# API COMMUNICATION (WITH CORRECT HEADERS)
# ============================================

call_deepseek_api() {
    local key="$1"
    local model="$2"
    local max_tokens="${3:-1}"
    
    curl -s -X POST "https://api.deepseek.com/anthropic/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $key" \
        -H "anthropic-version: 2023-06-01" \
        -d "{\"model\":\"$model\",\"max_tokens\":$max_tokens,\"messages\":[{\"role\":\"user\",\"content\":\"Hi\"}]}" \
        --max-time 10 2>/dev/null
}

validate_api_key() {
    local key="$1"
    local response
    
    response=$(call_deepseek_api "$key" "deepseek-chat" 1)
    
    if echo "$response" | grep -q '"id"'; then
        return 0
    fi
    return 1
}

test_model_availability() {
    local model="$1"
    local key="$2"
    local response
    
    response=$(call_deepseek_api "$key" "$model" 1)
    
    if echo "$response" | grep -q '"id"'; then
        return 0
    fi
    return 1
}

# ============================================
# MODEL SELECTION WITH FALLBACK
# ============================================

select_best_model() {
    local key="$1"
    local requested="${CLAUDESEEK_MODEL:-}"
    
    if [ -n "$requested" ]; then
        echo -e "${CYAN}🔍 Using requested model: $requested${NC}" >&2
        echo "$requested"
        return 0
    fi
    
    local models=("deepseek-v4-pro" "deepseek-v4-flash" "deepseek-chat")
    
    for model in "${models[@]}"; do
        echo -e "${CYAN}🔍 Testing $model...${NC}" >&2
        if test_model_availability "$model" "$key"; then
            echo -e "${GREEN}✅ Using $model${NC}" >&2
            echo "$model"
            return 0
        fi
        echo -e "${YELLOW}⚠️  $model unavailable, trying next...${NC}" >&2
    done
    
    echo -e "${YELLOW}⚠️  Using fallback: deepseek-chat${NC}" >&2
    echo "deepseek-chat"
}

# ============================================
# COMMAND HANDLERS
# ============================================

cmd_update() {
    echo -e "${BLUE}🔄 Updating claude-seek...${NC}"
    cd "$SCRIPT_DIR"
    npm update @anthropic-ai/claude-code 2>/dev/null || true
    echo -e "${GREEN}✅ Update complete${NC}"
    exit 0
}

cmd_config_set_key() {
    echo -e "${BLUE}🔑 Configure API Key${NC}"
    echo ""
    
    local key
    read -s -p "   Enter your DeepSeek API key: " key
    echo ""
    
    if [ -z "$key" ]; then
        echo -e "${RED}❌ No key provided${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🔍 Validating key...${NC}"
    
    if validate_api_key "$key"; then
        save_api_key "$key"
        echo -e "${GREEN}✅ Key saved and validated!${NC}"
    else
        echo -e "${RED}❌ Invalid API key${NC}"
        echo -e "${YELLOW}   Get your key from: https://platform.deepseek.com/api_keys${NC}"
        exit 1
    fi
    exit 0
}

cmd_config_unset_key() {
    echo -e "${BLUE}🗑️  Removing API key...${NC}"
    remove_api_key
    echo -e "${GREEN}✅ Key removed${NC}"
    exit 0
}

cmd_doctor() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🏥 claude-seek Doctor${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Node.js check
    echo -n "   Node.js: "
    if command -v node &> /dev/null; then
        echo -e "${GREEN}✓ $(node -v)${NC}"
    else
        echo -e "${RED}✗ Not found${NC}"
    fi
    
    # npm check
    echo -n "   npm: "
    if command -v npm &> /dev/null; then
        echo -e "${GREEN}✓ $(npm -v)${NC}"
    else
        echo -e "${RED}✗ Not found${NC}"
    fi
    
    # API key check
    echo -n "   API Key: "
    local key
    key=$(get_api_key)
    if [ -n "$key" ]; then
        echo -e "${GREEN}✓ Configured${NC}"
        echo -n "   Key Valid: "
        if validate_api_key "$key"; then
            echo -e "${GREEN}✓ Yes${NC}"
        else
            echo -e "${RED}✗ No - run 'claude-seek config set-key'${NC}"
        fi
    else
        echo -e "${RED}✗ Missing${NC}"
        echo -e "${YELLOW}   Run: claude-seek config set-key${NC}"
    fi
    
    # Models check
    if [ -n "$key" ]; then
        echo ""
        echo -e "${CYAN}   Model Availability:${NC}"
        for model in "deepseek-v4-pro" "deepseek-v4-flash" "deepseek-chat"; do
            echo -n "      $model: "
            if test_model_availability "$model" "$key"; then
                echo -e "${GREEN}✓ Available${NC}"
            else
                echo -e "${RED}✗ Unavailable${NC}"
            fi
        done
    fi
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
}

cmd_help() {
    cat << 'HELP'
claude-seek - Claude Code with DeepSeek Models

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
USAGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  claude-seek                    Start interactive session
  claude-seek -p "query"         Run query and exit
  claude-seek --model MODEL      Force specific model

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMMANDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  config set-key                 Configure API key
  config unset-key               Remove API key
  update                         Update to latest version
  doctor                         Health check
  --help, -h                     Show this help
  --version, -v                  Show version

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MODELS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  deepseek-v4-pro    Best quality, slower
  deepseek-v4-flash  Faster, good quality
  deepseek-chat      Fallback, always works

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EXAMPLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  claude-seek
  claude-seek -p "Write a Python function"
  claude-seek --model flash
  claude-seek config set-key
  claude-seek doctor

HELP
    exit 0
}

cmd_version() {
    echo "claude-seek v1.0.0"
    exit 0
}

# ============================================
# MAIN COMMAND DISPATCH
# ============================================

case "${1:-}" in
    update) cmd_update ;;
    config)
        case "${2:-}" in
            set-key) cmd_config_set_key ;;
            unset-key) cmd_config_unset_key ;;
            *) echo -e "${YELLOW}Usage: claude-seek config {set-key|unset-key}${NC}"; exit 1 ;;
        esac
        ;;
    doctor) cmd_doctor ;;
    --help|-h) cmd_help ;;
    --version|-v) cmd_version ;;
esac

# ============================================
# MAIN EXECUTION (no command or -p flag)
# ============================================

# Parse arguments
CLAUDESEEK_MODEL=""
ARGS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --model) CLAUDESEEK_MODEL="$2"; shift 2 ;;
        *) ARGS+=("$1"); shift ;;
    esac
done

# Get API key
API_KEY=$(get_api_key)
if [ -z "$API_KEY" ]; then
    echo -e "${RED}❌ Error: No API key found${NC}"
    echo -e "${YELLOW}   Run: claude-seek config set-key${NC}"
    exit 1
fi

# Validate API key
if ! validate_api_key "$API_KEY"; then
    echo -e "${RED}❌ Error: Invalid API key${NC}"
    echo -e "${YELLOW}   Run: claude-seek config set-key${NC}"
    exit 1
fi

# Select model
SELECTED_MODEL=$(select_best_model "$API_KEY")

# Set environment variables for Claude Code
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="$API_KEY"
export ANTHROPIC_MODEL="$SELECTED_MODEL"
export ANTHROPIC_SMALL_FAST_MODEL="deepseek-chat"

# Launch Claude Code
echo -e "${CYAN}🚀 Starting claude-seek with model: $SELECTED_MODEL${NC}"
echo ""
exec "$SCRIPT_DIR/node_modules/.bin/claude" "${ARGS[@]}"
EOF

chmod +x "$INSTALL_DIR/$WRAPPER_SCRIPT"
echo -e "${GREEN}   ✅ Wrapper script created${NC}"

# Add to PATH
echo -e "${BLUE}🔗 Adding to PATH...${NC}"

detect_profile() {
    case "$(basename "$SHELL")" in
        zsh) echo "$HOME/.zshrc" ;;
        bash)
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        fish) echo "$HOME/.config/fish/config.fish" ;;
        *) echo "" ;;
    esac
}

PROFILE=$(detect_profile)

if [ -n "$PROFILE" ] && [ -f "$PROFILE" ]; then
    if ! grep -q "/.claude-seek:" "$PROFILE" 2>/dev/null; then
        echo "export PATH=\"\$HOME/.claude-seek:\$PATH\"" >> "$PROFILE"
        echo -e "${GREEN}   ✅ Added to $PROFILE${NC}"
        echo -e "${YELLOW}   ⚠️  Run: source $PROFILE${NC}"
    else
        echo -e "${GREEN}   ✅ Already in PATH${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  Could not detect profile. Add manually:${NC}"
    echo -e "${YELLOW}   export PATH=\"\$HOME/.claude-seek:\$PATH\"${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo ""
echo -e "   ${CYAN}1. Configure your API key:${NC}"
echo -e "     ${YELLOW}claude-seek config set-key${NC}"
echo ""
echo -e "   ${CYAN}2. Run claude-seek:${NC}"
echo -e "     ${YELLOW}claude-seek${NC}"
echo ""
echo -e "   ${CYAN}3. Health check:${NC}"
echo -e "     ${YELLOW}claude-seek doctor${NC}"
echo ""
echo -e "${BLUE}📁 Installation directory: $INSTALL_DIR${NC}"
echo -e "${BLUE}🔧 Config directory: $CONFIG_DIR${NC}"
echo ""