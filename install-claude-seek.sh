#!/usr/bin/env bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

INSTALL_DIR="$HOME/.claude-seek"
WRAPPER_SCRIPT="claude-seek"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Installing claude-seek v1.2.0${NC}"
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
  "version": "1.2.0",
  "description": "Claude Code with DeepSeek models and session history",
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

# Create wrapper script
echo -e "${BLUE}📝 Creating wrapper script with history support...${NC}"
cat > "$INSTALL_DIR/$WRAPPER_SCRIPT" << 'WRAPPEREOF'
#!/bin/bash

# claude-seek v1.2.0 - Claude Code with DeepSeek

# Colors
if [ -z "${NO_COLOR:-}" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; MAGENTA=''; NC=''
fi

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.claude-seek"
HISTORY_DIR="$CONFIG_DIR/history"
LOG_DIR="$CONFIG_DIR/logs"

mkdir -p "$CONFIG_DIR" "$HISTORY_DIR" "$LOG_DIR"

# Config file
CONFIG_FILE="$CONFIG_DIR/config.env"

# Default config values
HISTORY_ENABLED="${HISTORY_ENABLED:-true}"
DEFAULT_MODEL="${DEFAULT_MODEL:-auto}"
SESSION_TIMEOUT_HOURS="${SESSION_TIMEOUT_HOURS:-24}"

# Load user config if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

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
# API COMMUNICATION
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
# HISTORY & SESSION MANAGEMENT
# ============================================

get_session_id() {
    echo "$(date +%Y%m%d_%H%M%S)_$$"
}

get_session_file() {
    local session_id="$1"
    echo "$HISTORY_DIR/${session_id}.session"
}

save_session_start() {
    local session_id="$1"
    local project_dir="$2"
    local model="$3"
    
    cat > "$(get_session_file "$session_id")" << SESSIONEOF
SESSION_ID=$session_id
START_TIME=$(date +%s)
START_DATE=$(date)
PROJECT_DIR=$project_dir
MODEL=$model
SESSIONEOF
}

save_session_command() {
    local session_id="$1"
    local command="$2"
    local session_file="$HISTORY_DIR/${session_id}.session"
    if [ -f "$session_file" ]; then
        echo "COMMAND_$(date +%s)=\"$command\"" >> "$session_file"
    fi
}

list_sessions() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📜 Session History${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ ! -d "$HISTORY_DIR" ] || [ -z "$(ls -A "$HISTORY_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}   No sessions found${NC}"
        echo ""
        return
    fi
    
    printf "   %-20s %-20s %-15s %-10s\n" "SESSION ID" "DATE" "MODEL" "CMDS"
    printf "   %-20s %-20s %-15s %-10s\n" "---------" "----" "-----" "----"
    
    for session_file in "$HISTORY_DIR"/*.session; do
        if [ -f "$session_file" ]; then
            local session_id=$(grep "^SESSION_ID=" "$session_file" | cut -d'=' -f2)
            local start_date=$(grep "^START_DATE=" "$session_file" | cut -d'=' -f2-)
            local model=$(grep "^MODEL=" "$session_file" | cut -d'=' -f2)
            local cmd_count=$(grep "^COMMAND_" "$session_file" | wc -l)
            
            session_id="${session_id:0:20}"
            start_date="${start_date:0:20}"
            model="${model:0:15}"
            
            printf "   %-20s %-20s %-15s %-10s\n" "$session_id" "$start_date" "$model" "$cmd_count"
        fi
    done
    echo ""
}

show_session() {
    local session_id="$1"
    local session_file="$HISTORY_DIR/${session_id}.session"
    
    if [ ! -f "$session_file" ]; then
        echo -e "${RED}❌ Session not found: $session_id${NC}"
        return 1
    fi
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}📄 Session Details: $session_id${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    local start_date=$(grep "^START_DATE=" "$session_file" | cut -d'=' -f2-)
    local project_dir=$(grep "^PROJECT_DIR=" "$session_file" | cut -d'=' -f2-)
    local model=$(grep "^MODEL=" "$session_file" | cut -d'=' -f2)
    
    echo -e "${CYAN}   Date:${NC} $start_date"
    echo -e "${CYAN}   Project:${NC} $project_dir"
    echo -e "${CYAN}   Model:${NC} $model"
    echo ""
    
    echo -e "${CYAN}   Commands:${NC}"
    grep "^COMMAND_" "$session_file" | while read line; do
        local cmd=$(echo "$line" | cut -d'=' -f2-)
        echo -e "      ${YELLOW}→${NC} $cmd"
    done
    echo ""
}

clear_history() {
    echo -e "${YELLOW}⚠️  This will delete all session history.${NC}"
    read -p "Are you sure? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$HISTORY_DIR"/*
        mkdir -p "$HISTORY_DIR"
        echo -e "${GREEN}✅ History cleared${NC}"
    else
        echo -e "${GREEN}Cancelled${NC}"
    fi
}

# ============================================
# MODEL SELECTION
# ============================================

select_best_model() {
    local key="$1"
    local requested="${CLAUDESEEK_MODEL:-}"
    
    if [ -n "$requested" ]; then
        echo -e "${CYAN}🔍 Using requested model: $requested${NC}" >&2
        echo "$requested"
        return 0
    fi
    
    if [ "$DEFAULT_MODEL" != "auto" ] && [ -n "$DEFAULT_MODEL" ]; then
        echo -e "${CYAN}🔍 Using default model: $DEFAULT_MODEL${NC}" >&2
        if test_model_availability "$DEFAULT_MODEL" "$key"; then
            echo "$DEFAULT_MODEL"
            return 0
        fi
        echo -e "${YELLOW}⚠️  Default model unavailable, trying fallback...${NC}" >&2
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
# SETUP WIZARD
# ============================================

run_setup_wizard() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}✨ claude-seek Setup Wizard${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${CYAN}📝 Step 1/4: API Key${NC}"
    echo -e "${YELLOW}   Get your key from: https://platform.deepseek.com/api_keys${NC}"
    read -s -p "   Enter your DeepSeek API key: " api_key
    echo ""
    
    if [ -z "$api_key" ]; then
        echo -e "${RED}❌ No key provided. Setup cancelled.${NC}"
        return 1
    fi
    
    echo -e "${BLUE}   🔍 Validating key...${NC}"
    if validate_api_key "$api_key"; then
        save_api_key "$api_key"
        echo -e "${GREEN}   ✅ Key validated and saved!${NC}"
    else
        echo -e "${RED}   ❌ Invalid API key.${NC}"
        return 1
    fi
    echo ""
    
    echo -e "${CYAN}🎯 Step 2/4: Default Model${NC}"
    echo "   1) deepseek-v4-pro (best quality, slower)"
    echo "   2) deepseek-v4-flash (faster, good quality)"
    echo "   3) auto (let claude-seek choose)"
    read -p "   Choice (1/2/3) [3]: " model_choice
    
    case "$model_choice" in
        1) DEFAULT_MODEL="deepseek-v4-pro" ;;
        2) DEFAULT_MODEL="deepseek-v4-flash" ;;
        *) DEFAULT_MODEL="auto" ;;
    esac
    echo ""
    
    echo -e "${CYAN}📜 Step 3/4: History Settings${NC}"
    read -p "   Enable session history? (Y/n): " history_choice
    if [[ "$history_choice" =~ ^[Nn]$ ]]; then
        HISTORY_ENABLED="false"
    else
        HISTORY_ENABLED="true"
    fi
    
    if [ "$HISTORY_ENABLED" = "true" ]; then
        read -p "   Session timeout (hours) [24]: " timeout_input
        SESSION_TIMEOUT_HOURS="${timeout_input:-24}"
    fi
    echo ""
    
    echo -e "${CYAN}🎨 Step 4/4: Output Preferences${NC}"
    read -p "   Show colored output? (Y/n): " color_choice
    if [[ "$color_choice" =~ ^[Nn]$ ]]; then
        NO_COLOR="true"
    else
        NO_COLOR="false"
    fi
    echo ""
    
    cat > "$CONFIG_FILE" << CONFIGEOF
HISTORY_ENABLED=$HISTORY_ENABLED
SESSION_TIMEOUT_HOURS=$SESSION_TIMEOUT_HOURS
DEFAULT_MODEL=$DEFAULT_MODEL
NO_COLOR=$NO_COLOR
CONFIGEOF
    
    echo -e "${GREEN}   ✅ Configuration saved${NC}"
    echo ""
    
    echo -e "${BLUE}🔍 Testing connection...${NC}"
    if test_model_availability "deepseek-chat" "$api_key"; then
        echo -e "${GREEN}✅ Connection successful!${NC}"
    else
        echo -e "${YELLOW}⚠️  Connection test failed${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 Setup complete! Run 'claude-seek' to start.${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ============================================
# COMMAND HANDLERS
# ============================================

cmd_update() {
    echo -e "${BLUE}🔄 Updating...${NC}"
    cd "$SCRIPT_DIR"
    npm update @anthropic-ai/claude-code 2>/dev/null || true
    echo -e "${GREEN}✅ Updated${NC}"
    exit 0
}

cmd_config_set_key() {
    echo -e "${BLUE}🔑 Set API Key${NC}"
    read -s -p "   Enter your DeepSeek API key: " key
    echo ""
    if [ -z "$key" ]; then
        echo -e "${RED}❌ No key provided${NC}"
        exit 1
    fi
    if validate_api_key "$key"; then
        save_api_key "$key"
        echo -e "${GREEN}✅ Key saved${NC}"
    else
        echo -e "${RED}❌ Invalid key${NC}"
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

cmd_config_show() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}⚙️  Current Configuration${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "   History: $( [ "$HISTORY_ENABLED" = "true" ] && echo "Enabled" || echo "Disabled" )"
    echo "   Session Timeout: ${SESSION_TIMEOUT_HOURS} hour(s)"
    echo "   Default Model: $DEFAULT_MODEL"
    echo "   Color Output: $( [ "$NO_COLOR" = "false" ] && echo "Enabled" || echo "Disabled" )"
    echo ""
}

cmd_config() {
    case "${1:-}" in
        set-key) cmd_config_set_key ;;
        unset-key) cmd_config_unset_key ;;
        show) cmd_config_show ;;
        *) echo "Usage: claude-seek config {set-key|unset-key|show}"; exit 1 ;;
    esac
}

cmd_history() {
    case "${1:-}" in
        list) list_sessions ;;
        show) shift; show_session "$1" ;;
        clear) clear_history ;;
        *) echo "Usage: claude-seek history {list|show <id>|clear}"; exit 1 ;;
    esac
    exit 0
}

cmd_doctor() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🏥 claude-seek Doctor${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -n "   Node.js: "
    if command -v node &> /dev/null; then
        echo -e "${GREEN}✓ $(node -v)${NC}"
    else
        echo -e "${RED}✗ Not found${NC}"
    fi
    
    echo -n "   npm: "
    if command -v npm &> /dev/null; then
        echo -e "${GREEN}✓ $(npm -v)${NC}"
    else
        echo -e "${RED}✗ Not found${NC}"
    fi
    
    echo -n "   API Key: "
    local key
    key=$(get_api_key)
    if [ -n "$key" ]; then
        echo -e "${GREEN}✓ Configured${NC}"
        echo -n "   Key Valid: "
        if validate_api_key "$key"; then
            echo -e "${GREEN}✓ Yes${NC}"
        else
            echo -e "${RED}✗ No${NC}"
        fi
    else
        echo -e "${RED}✗ Missing${NC}"
    fi
    
    echo -n "   History: "
    if [ "$HISTORY_ENABLED" = "true" ]; then
        echo -e "${GREEN}✓ Enabled${NC}"
        local session_count
        session_count=$(find "$HISTORY_DIR" -name "*.session" 2>/dev/null | wc -l)
        echo -e "   Sessions: ${CYAN}$session_count${NC}"
    else
        echo -e "${YELLOW}○ Disabled${NC}"
    fi
    
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
    cat << 'HELPEOF'
claude-seek v1.2.0 - Claude Code with DeepSeek Models

USAGE:
  claude-seek                    Start interactive session
  claude-seek -p "query"         Run query and exit
  claude-seek --model MODEL      Force specific model

COMMANDS:
  setup                          Interactive setup wizard
  config set-key                 Configure API key
  config unset-key               Remove API key
  config show                    Show current settings
  history list                   List all sessions
  history show <id>              Show session details
  history clear                  Clear all history
  update                         Update to latest version
  doctor                         Health check
  --help, -h                     Show this help
  --version, -v                  Show version

MODELS:
  deepseek-v4-pro    Best quality, slower
  deepseek-v4-flash  Faster, good quality
  deepseek-chat      Fallback, always works

EXAMPLES:
  claude-seek setup
  claude-seek -p "Write a Python function"
  claude-seek --model flash
  claude-seek history list
HELPEOF
    exit 0
}

cmd_version() {
    echo "claude-seek v1.2.0"
    exit 0
}

# ============================================
# MAIN DISPATCH
# ============================================

case "${1:-}" in
    update) cmd_update ;;
    setup) run_setup_wizard ;;
    config) shift; cmd_config "$@" ;;
    history) shift; cmd_history "$@" ;;
    doctor) cmd_doctor ;;
    --help|-h) cmd_help ;;
    --version|-v) cmd_version ;;
esac

# ============================================
# MAIN EXECUTION
# ============================================

CLAUDESEEK_MODEL=""
ARGS=()
SESSION_ID=""

while [ $# -gt 0 ]; do
    case "$1" in
        --model) CLAUDESEEK_MODEL="$2"; shift 2 ;;
        *) ARGS+=("$1"); shift ;;
    esac
done

API_KEY=$(get_api_key)
if [ -z "$API_KEY" ]; then
    echo -e "${RED}❌ Error: No API key found${NC}"
    echo -e "${YELLOW}   Run: claude-seek setup${NC}"
    exit 1
fi

if ! validate_api_key "$API_KEY"; then
    echo -e "${RED}❌ Error: Invalid API key${NC}"
    exit 1
fi

SELECTED_MODEL=$(select_best_model "$API_KEY")

if [ "$HISTORY_ENABLED" = "true" ]; then
    SESSION_ID=$(get_session_id)
    save_session_start "$SESSION_ID" "$(pwd)" "$SELECTED_MODEL"
fi

export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="$API_KEY"
export ANTHROPIC_MODEL="$SELECTED_MODEL"
export ANTHROPIC_SMALL_FAST_MODEL="deepseek-chat"

echo -e "${CYAN}🚀 Starting claude-seek with model: $SELECTED_MODEL${NC}"
if [ -n "$SESSION_ID" ]; then
    echo -e "${CYAN}📝 Session: $SESSION_ID${NC}"
fi
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
echo -e "${GREEN}🎉 Installation complete! (v1.2.0)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Quick Start:${NC}"
echo "   claude-seek setup"
echo "   claude-seek"
echo ""
echo -e "${BLUE}📚 New commands:${NC}"
echo "   claude-seek history list"
echo "   claude-seek history show <id>"
echo "   claude-seek config show"
echo ""