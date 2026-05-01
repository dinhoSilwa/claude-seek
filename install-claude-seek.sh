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
echo -e "${BLUE}🚀 Installing claude-seek v1.3.0${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check Node.js
echo -e "${BLUE}📋 Checking prerequisites...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not found${NC}"
    exit 1
fi
echo -e "${GREEN}   ✅ Node.js $(node -v)${NC}"

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
    cat > package.json << 'PKGEOF'
{
  "name": "claude-seek",
  "version": "1.3.0",
  "description": "Claude Code with DeepSeek models",
  "private": true
}
PKGEOF
    echo -e "${GREEN}   ✅ package.json created${NC}"
fi

# Install dependency
echo -e "${BLUE}⬇️  Installing dependency...${NC}"
npm install @anthropic-ai/claude-code
echo -e "${GREEN}   ✅ Installation complete${NC}"
echo ""

# Create wrapper script (FINAL CLEAN VERSION)
echo -e "${BLUE}📝 Creating wrapper script...${NC}"
cat > "$INSTALL_DIR/$WRAPPER_SCRIPT" << 'WRAPPEREOF'
#!/bin/bash

# claude-seek v1.3.0 - Claude Code with DeepSeek

set -e

# Colors (with safety checks)
if [ -z "${NO_COLOR:-}" ] && [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; BOLD=''; DIM=''; NC=''
fi

# Icons
ICON_CHECK="✓"
ICON_CROSS="✗"
ICON_WARN="⚠"
ICON_INFO="ℹ"
ICON_ROCKET="🚀"

# ============================================
# PATHS
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.claude-seek"
HISTORY_DIR="$CONFIG_DIR/history"
LOG_DIR="$CONFIG_DIR/logs"

mkdir -p "$CONFIG_DIR" "$HISTORY_DIR" "$LOG_DIR"

CONFIG_FILE="$CONFIG_DIR/config.env"

# Default values (safety first)
HISTORY_ENABLED="${HISTORY_ENABLED:-true}"
DEFAULT_MODEL="${DEFAULT_MODEL:-auto}"
SESSION_TIMEOUT_HOURS="${SESSION_TIMEOUT_HOURS:-24}"
NO_COLOR="${NO_COLOR:-false}"
LOG_LEVEL="${LOG_LEVEL:-info}"

# Load user config if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# ============================================
# LOGGING
# ============================================

LOG_FILE="$LOG_DIR/claude-seek-$(date +%Y%m%d).log"

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

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
    echo "$1" > "$CONFIG_DIR/key"
    chmod 600 "$CONFIG_DIR/key"
    log_msg "API key saved"
}

remove_api_key() {
    rm -f "$CONFIG_DIR/key"
    log_msg "API key removed"
}

# ============================================
# API COMMUNICATION
# ============================================

call_deepseek_api() {
    local key="$1"
    local model="$2"
    
    curl -s -X POST "https://api.deepseek.com/anthropic/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $key" \
        -H "anthropic-version: 2023-06-01" \
        -d "{\"model\":\"$model\",\"max_tokens\":1,\"messages\":[{\"role\":\"user\",\"content\":\"Hi\"}]}" \
        --max-time 10 2>/dev/null
}

validate_api_key() {
    local key="$1"
    local response
    response=$(call_deepseek_api "$key" "deepseek-chat")
    echo "$response" | grep -q '"id"'
}

test_model() {
    local model="$1"
    local key="$2"
    local response
    response=$(call_deepseek_api "$key" "$model")
    echo "$response" | grep -q '"id"'
}

# ============================================
# MODEL SELECTION
# ============================================

select_model() {
    local key="$1"
    local requested="$2"
    
    if [ -n "$requested" ]; then
        echo "$requested"
        return 0
    fi
    
    if [ "$DEFAULT_MODEL" != "auto" ] && [ -n "$DEFAULT_MODEL" ]; then
        if test_model "$DEFAULT_MODEL" "$key"; then
            echo "$DEFAULT_MODEL"
            return 0
        fi
    fi
    
    for model in "deepseek-v4-pro" "deepseek-v4-flash" "deepseek-chat"; do
        if test_model "$model" "$key"; then
            echo "$model"
            return 0
        fi
    done
    
    echo "deepseek-chat"
}

# ============================================
# SESSION MANAGEMENT
# ============================================

get_session_id() {
    echo "$(date +%Y%m%d_%H%M%S)_$$"
}

save_session() {
    local session_id="$1"
    local project="$2"
    local model="$3"
    
    cat > "$HISTORY_DIR/${session_id}.session" << SESSIONEOF
SESSION_ID=$session_id
START_DATE=$(date)
PROJECT_DIR=$project
MODEL=$model
SESSIONEOF
    log_msg "Session started: $session_id"
}

list_sessions() {
    if [ ! -d "$HISTORY_DIR" ] || [ -z "$(ls -A "$HISTORY_DIR" 2>/dev/null)" ]; then
        echo "   No sessions found"
        return
    fi
    
    printf "   %-20s %-20s %-15s\n" "SESSION ID" "DATE" "MODEL"
    printf "   %-20s %-20s %-15s\n" "---------" "----" "-----"
    
    for f in "$HISTORY_DIR"/*.session; do
        if [ -f "$f" ]; then
            local id=$(grep "^SESSION_ID=" "$f" | cut -d'=' -f2)
            local date=$(grep "^START_DATE=" "$f" | cut -d'=' -f2-)
            local model=$(grep "^MODEL=" "$f" | cut -d'=' -f2)
            printf "   %-20s %-20s %-15s\n" "${id:0:20}" "${date:0:20}" "${model:0:15}"
        fi
    done
}

show_session() {
    local session_id="$1"
    local f="$HISTORY_DIR/${session_id}.session"
    
    if [ ! -f "$f" ]; then
        echo -e "${RED}${ICON_CROSS} Session not found${NC}"
        return 1
    fi
    
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}Session: $session_id${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    local date=$(grep "^START_DATE=" "$f" | cut -d'=' -f2-)
    local project=$(grep "^PROJECT_DIR=" "$f" | cut -d'=' -f2-)
    local model=$(grep "^MODEL=" "$f" | cut -d'=' -f2)
    
    echo "   Date:    $date"
    echo "   Project: $project"
    echo "   Model:   $model"
    echo ""
}

clear_history() {
    rm -rf "$HISTORY_DIR"/*
    mkdir -p "$HISTORY_DIR"
    echo -e "${GREEN}${ICON_CHECK} History cleared${NC}"
    log_msg "History cleared"
}

# ============================================
# SETUP WIZARD
# ============================================

run_setup() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}✨ claude-seek Setup Wizard${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${CYAN}Step 1: API Key${NC}"
    read -s -p "   Enter your DeepSeek API key: " api_key
    echo ""
    
    if [ -z "$api_key" ]; then
        echo -e "${RED}${ICON_CROSS} No key provided${NC}"
        return 1
    fi
    
    echo -e "${CYAN}   Validating...${NC}"
    if validate_api_key "$api_key"; then
        save_api_key "$api_key"
        echo -e "${GREEN}${ICON_CHECK} Key validated and saved${NC}"
    else
        echo -e "${RED}${ICON_CROSS} Invalid API key${NC}"
        return 1
    fi
    echo ""
    
    echo -e "${CYAN}Step 2: Default Model${NC}"
    echo "   1) deepseek-v4-pro (best quality)"
    echo "   2) deepseek-v4-flash (faster)"
    echo "   3) auto (let claude-seek choose)"
    read -p "   Choice (1/2/3) [3]: " choice
    case "$choice" in
        1) DEFAULT_MODEL="deepseek-v4-pro" ;;
        2) DEFAULT_MODEL="deepseek-v4-flash" ;;
        *) DEFAULT_MODEL="auto" ;;
    esac
    echo ""
    
    echo -e "${CYAN}Step 3: History${NC}"
    read -p "   Enable session history? (Y/n): " hist_choice
    if [[ "$hist_choice" =~ ^[Nn]$ ]]; then
        HISTORY_ENABLED="false"
    else
        HISTORY_ENABLED="true"
    fi
    echo ""
    
    echo -e "${CYAN}Step 4: Colors${NC}"
    read -p "   Enable colored output? (Y/n): " color_choice
    if [[ "$color_choice" =~ ^[Nn]$ ]]; then
        NO_COLOR="true"
    else
        NO_COLOR="false"
    fi
    echo ""
    
    cat > "$CONFIG_FILE" << EOF
HISTORY_ENABLED=$HISTORY_ENABLED
DEFAULT_MODEL=$DEFAULT_MODEL
SESSION_TIMEOUT_HOURS=24
NO_COLOR=$NO_COLOR
LOG_LEVEL=info
EOF
    
    echo -e "${GREEN}${ICON_CHECK} Configuration saved${NC}"
    echo ""
    echo -e "${GREEN}${ICON_CHECK} Setup complete! Run 'claude-seek' to start${NC}"
}

# ============================================
# COMMANDS
# ============================================

cmd_set_key() {
    echo -e "${BLUE}${ICON_GEAR:-[CFG]} Set API Key${NC}"
    read -s -p "   Enter your DeepSeek API key: " key
    echo ""
    if [ -z "$key" ]; then
        echo -e "${RED}${ICON_CROSS} No key provided${NC}"
        exit 1
    fi
    if validate_api_key "$key"; then
        save_api_key "$key"
        echo -e "${GREEN}${ICON_CHECK} Key saved${NC}"
    else
        echo -e "${RED}${ICON_CROSS} Invalid key${NC}"
        exit 1
    fi
    exit 0
}

cmd_unset_key() {
    remove_api_key
    echo -e "${GREEN}${ICON_CHECK} Key removed${NC}"
    exit 0
}

cmd_show_config() {
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}Configuration${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "   History:        $([ "$HISTORY_ENABLED" = "true" ] && echo "Enabled" || echo "Disabled")"
    echo "   Default Model:  $DEFAULT_MODEL"
    echo "   Color Output:   $([ "$NO_COLOR" = "false" ] && echo "Enabled" || echo "Disabled")"
    echo "   Log Level:      $LOG_LEVEL"
    echo ""
}

cmd_doctor() {
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}🏥 claude-seek Doctor${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo "System:"
    echo "   Node.js: $(node -v 2>/dev/null || echo 'not found')"
    echo "   npm: $(npm -v 2>/dev/null || echo 'not found')"
    echo "   OS: $(uname -s)"
    echo ""
    
    echo "API Key:"
    local key=$(get_api_key)
    if [ -n "$key" ]; then
        echo "   Status: Configured"
        if validate_api_key "$key"; then
            echo "   Valid: Yes"
        else
            echo "   Valid: No"
        fi
    else
        echo "   Status: Missing"
        echo "   Run: claude-seek config set-key"
    fi
    echo ""
    
    echo "History:"
    echo "   Status: $([ "$HISTORY_ENABLED" = "true" ] && echo "Enabled" || echo "Disabled")"
    local count=$(find "$HISTORY_DIR" -name "*.session" 2>/dev/null | wc -l)
    echo "   Sessions: $count"
    echo ""
    
    if [ -n "$key" ] && validate_api_key "$key"; then
        echo "Models:"
        for m in "deepseek-v4-pro" "deepseek-v4-flash" "deepseek-chat"; do
            if test_model "$m" "$key"; then
                echo "   $m: Available"
            else
                echo "   $m: Unavailable"
            fi
        done
        echo ""
    fi
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

cmd_help() {
    cat << 'EOF'
claude-seek v1.3.0 - Claude Code with DeepSeek

USAGE:
  claude-seek                    Start interactive session
  claude-seek -p "query"         Run query and exit
  claude-seek --model MODEL      Force specific model

COMMANDS:
  setup              Interactive setup wizard
  config set-key     Configure API key
  config unset-key   Remove API key
  config show        Show current settings
  history list       List all sessions
  history show <id>  Show session details
  history clear      Clear all history
  doctor             Health check
  --help, -h         Show this help
  --version, -v      Show version

ENVIRONMENT:
  DEEPSEEK_API_KEY   Set API key directly
  NO_COLOR           Disable colored output

EXAMPLES:
  claude-seek setup
  claude-seek -p "Write a function"
  claude-seek --model flash
EOF
    exit 0
}

# ============================================
# MAIN DISPATCH
# ============================================

case "${1:-}" in
    setup) run_setup ;;
    config)
        case "${2:-}" in
            set-key) cmd_set_key ;;
            unset-key) cmd_unset_key ;;
            show) cmd_show_config ;;
            *) echo "Usage: claude-seek config {set-key|unset-key|show}"; exit 1 ;;
        esac
        ;;
    history)
        case "${2:-}" in
            list) list_sessions ;;
            show) shift 2; show_session "$1" ;;
            clear) clear_history ;;
            *) echo "Usage: claude-seek history {list|show <id>|clear}"; exit 1 ;;
        esac
        ;;
    doctor) cmd_doctor ;;
    --help|-h) cmd_help ;;
    --version|-v) echo "claude-seek v1.3.0"; exit 0 ;;
esac

# ============================================
# MAIN EXECUTION
# ============================================

CLAUDESEEK_MODEL=""
ARGS=()

while [ $# -gt 0 ]; do
    case "$1" in
        --model) CLAUDESEEK_MODEL="$2"; shift 2 ;;
        *) ARGS+=("$1"); shift ;;
    esac
done

API_KEY=$(get_api_key)
if [ -z "$API_KEY" ]; then
    echo -e "${RED}${ICON_CROSS} Error: No API key found${NC}"
    echo -e "${YELLOW}${ICON_WARN} Run: claude-seek setup${NC}"
    exit 1
fi

if ! validate_api_key "$API_KEY"; then
    echo -e "${RED}${ICON_CROSS} Error: Invalid API key${NC}"
    exit 1
fi

SELECTED_MODEL=$(select_model "$API_KEY" "$CLAUDESEEK_MODEL")

if [ "$HISTORY_ENABLED" = "true" ]; then
    SESSION_ID=$(get_session_id)
    save_session "$SESSION_ID" "$(pwd)" "$SELECTED_MODEL"
fi

export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="$API_KEY"
export ANTHROPIC_MODEL="$SELECTED_MODEL"

echo -e "${CYAN}${ICON_ROCKET} Starting claude-seek with model: $SELECTED_MODEL${NC}"
echo ""

exec "$SCRIPT_DIR/node_modules/.bin/claude" "${ARGS[@]}"
WRAPPEREOF

chmod +x "$INSTALL_DIR/$WRAPPER_SCRIPT"
echo -e "${GREEN}   ✅ Wrapper script created${NC}"

# Add to PATH
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
        *) echo "" ;;
    esac
}

PROFILE=$(detect_profile)

if [ -n "$PROFILE" ] && [ -f "$PROFILE" ]; then
    if ! grep -q "/.claude-seek:" "$PROFILE" 2>/dev/null; then
        echo "export PATH=\"\$HOME/.claude-seek:\$PATH\"" >> "$PROFILE"
        echo -e "${GREEN}   ✅ Added to $PROFILE${NC}"
    fi
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Installation complete! (v1.3.0)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Quick Start:${NC}"
echo "   claude-seek setup"
echo "   claude-seek"
echo ""
echo -e "${BLUE}Commands:${NC}"
echo "   claude-seek doctor"
echo "   claude-seek config show"
echo "   claude-seek history list"
echo ""