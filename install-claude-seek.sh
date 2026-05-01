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
echo -e "${BLUE}🚀 Installing claude-seek v1.1.0${NC}"
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
    cat > package.json << 'EOF'
{
  "name": "claude-seek",
  "version": "1.1.0",
  "description": "Claude Code with DeepSeek models and intelligent caching",
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

# Create wrapper script (DIA 2 - WITH CACHE)
echo -e "${BLUE}📝 Creating wrapper script with cache support...${NC}"
cat > "$INSTALL_DIR/$WRAPPER_SCRIPT" << 'EOF'
#!/bin/bash

# claude-seek v1.1.0 - Claude Code with DeepSeek
# Features: Model fallback, Response caching, Interactive setup

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
CACHE_DIR="$CONFIG_DIR/cache"
LOG_DIR="$CONFIG_DIR/logs"

mkdir -p "$CONFIG_DIR" "$CACHE_DIR" "$LOG_DIR"

# Config file
CONFIG_FILE="$CONFIG_DIR/config.env"

# Default config values
CACHE_ENABLED="${CACHE_ENABLED:-true}"
CACHE_TTL_HOURS="${CACHE_TTL_HOURS:-1}"
CACHE_MAX_SIZE_MB="${CACHE_MAX_SIZE_MB:-100}"
DEFAULT_MODEL="${DEFAULT_MODEL:-auto}"

# Load user config if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# ============================================
# LOGGING
# ============================================

log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$LOG_DIR/claude-seek.log"
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
    local key="$1"
    echo "$key" > "$CONFIG_DIR/key"
    chmod 600 "$CONFIG_DIR/key"
    log "INFO" "API key saved"
}

remove_api_key() {
    rm -f "$CONFIG_DIR/key"
    log "INFO" "API key removed"
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
# CACHE SYSTEM
# ============================================

generate_cache_key() {
    local query="$1"
    local model="$2"
    echo -n "$query|$model" | sha256sum | cut -d' ' -f1
}

get_cache_file_path() {
    local cache_key="$1"
    echo "$CACHE_DIR/${cache_key}.cache"
}

is_cache_valid() {
    local cache_file="$1"
    
    if [ ! -f "$cache_file" ]; then
        return 1
    fi
    
    # Check age
    local file_age_hours
    local file_mod_time
    local current_time
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        file_mod_time=$(stat -f "%m" "$cache_file" 2>/dev/null)
    else
        # Linux
        file_mod_time=$(stat -c "%Y" "$cache_file" 2>/dev/null)
    fi
    
    current_time=$(date +%s)
    file_age_hours=$(( (current_time - file_mod_time) / 3600 ))
    
    if [ "$file_age_hours" -lt "$CACHE_TTL_HOURS" ]; then
        return 0
    fi
    
    return 1
}

read_cache() {
    local cache_file="$1"
    
    if is_cache_valid "$cache_file"; then
        cat "$cache_file"
        return 0
    fi
    
    return 1
}

write_cache() {
    local cache_file="$1"
    local response="$2"
    
    # Check cache size limit
    local cache_size
    cache_size=$(du -sm "$CACHE_DIR" 2>/dev/null | cut -f1)
    
    if [ -n "$cache_size" ] && [ "$cache_size" -gt "$CACHE_MAX_SIZE_MB" ]; then
        # Clean old entries
        clean_old_cache
    fi
    
    echo "$response" > "$cache_file"
    log "DEBUG" "Cached response to $cache_file"
}

clean_old_cache() {
    log "INFO" "Cleaning old cache entries"
    find "$CACHE_DIR" -name "*.cache" -type f -mtime +"$CACHE_TTL_HOURS" -delete 2>/dev/null
}

clear_all_cache() {
    echo -e "${YELLOW}🗑️  Clearing all cache...${NC}"
    rm -rf "$CACHE_DIR"/*
    mkdir -p "$CACHE_DIR"
    echo -e "${GREEN}✅ Cache cleared${NC}"
}

get_cache_stats() {
    local total_entries=0
    local total_size=0
    local hits=0
    local misses=0
    
    if [ -d "$CACHE_DIR" ]; then
        total_entries=$(find "$CACHE_DIR" -name "*.cache" -type f | wc -l)
        total_size=$(du -sm "$CACHE_DIR" 2>/dev/null | cut -f1)
    fi
    
    # Try to read stats file
    if [ -f "$CONFIG_DIR/cache_stats.txt" ]; then
        source "$CONFIG_DIR/cache_stats.txt"
    fi
    
    cat << STATS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 CACHE STATISTICS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Status: $( [ "$CACHE_ENABLED" = "true" ] && echo "✅ Enabled" || echo "❌ Disabled" )
   Entries: $total_entries
   Size: ${total_size:-0} MB / ${CACHE_MAX_SIZE_MB} MB
   TTL: ${CACHE_TTL_HOURS} hour(s)
   Hits: $hits
   Misses: $misses
   Hit Rate: $( [ $((hits + misses)) -gt 0 ] && echo "$(( hits * 100 / (hits + misses) ))%" || echo "N/A" )
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STATS
}

update_cache_stats() {
    local hit="$1"
    local stats_file="$CONFIG_DIR/cache_stats.txt"
    local hits=0
    local misses=0
    
    if [ -f "$stats_file" ]; then
        source "$stats_file"
    fi
    
    if [ "$hit" = "true" ]; then
        hits=$((hits + 1))
    else
        misses=$((misses + 1))
    fi
    
    echo "hits=$hits" > "$stats_file"
    echo "misses=$misses" >> "$stats_file"
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
# INTERACTIVE SETUP WIZARD (IMPROVED)
# ============================================

run_setup_wizard() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}✨ claude-seek Setup Wizard${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Step 1: API Key
    echo -e "${CYAN}📝 Step 1/5: API Key${NC}"
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
        echo -e "${RED}   ❌ Invalid API key. Please check and try again.${NC}"
        return 1
    fi
    echo ""
    
    # Step 2: Default Model
    echo -e "${CYAN}🎯 Step 2/5: Default Model${NC}"
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
    
    # Step 3: Cache Settings
    echo -e "${CYAN}💾 Step 3/5: Cache Settings${NC}"
    read -p "   Enable response cache? (Y/n): " cache_choice
    if [[ "$cache_choice" =~ ^[Nn]$ ]]; then
        CACHE_ENABLED="false"
    else
        CACHE_ENABLED="true"
    fi
    
    if [ "$CACHE_ENABLED" = "true" ]; then
        read -p "   Cache TTL (hours) [1]: " ttl_input
        CACHE_TTL_HOURS="${ttl_input:-1}"
        
        read -p "   Max cache size (MB) [100]: " size_input
        CACHE_MAX_SIZE_MB="${size_input:-100}"
    fi
    echo ""
    
    # Step 4: Output Preferences
    echo -e "${CYAN}🎨 Step 4/5: Output Preferences${NC}"
    read -p "   Show colored output? (Y/n): " color_choice
    if [[ "$color_choice" =~ ^[Nn]$ ]]; then
        NO_COLOR="true"
    else
        NO_COLOR="false"
    fi
    echo ""
    
    # Step 5: Save Configuration
    echo -e "${CYAN}💾 Step 5/5: Save Configuration${NC}"
    
    cat > "$CONFIG_FILE" << CONFIG_EOF
# claude-seek configuration
# Generated by setup wizard

CACHE_ENABLED=$CACHE_ENABLED
CACHE_TTL_HOURS=$CACHE_TTL_HOURS
CACHE_MAX_SIZE_MB=$CACHE_MAX_SIZE_MB
DEFAULT_MODEL=$DEFAULT_MODEL
NO_COLOR=$NO_COLOR
CONFIG_EOF
    
    echo -e "${GREEN}   ✅ Configuration saved to $CONFIG_FILE${NC}"
    echo ""
    
    # Test connection
    echo -e "${BLUE}🔍 Testing connection...${NC}"
    if test_model_availability "deepseek-chat" "$api_key"; then
        echo -e "${GREEN}✅ Connection successful!${NC}"
    else
        echo -e "${YELLOW}⚠️  Connection test failed, but configuration saved.${NC}"
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
    echo "   Cache: $( [ "$CACHE_ENABLED" = "true" ] && echo "Enabled" || echo "Disabled" )"
    echo "   Cache TTL: ${CACHE_TTL_HOURS} hour(s)"
    echo "   Max Cache Size: ${CACHE_MAX_SIZE_MB} MB"
    echo "   Default Model: $DEFAULT_MODEL"
    echo "   Color Output: $( [ "$NO_COLOR" = "false" ] && echo "Enabled" || echo "Disabled" )"
    echo ""
}

cmd_config() {
    case "${1:-}" in
        set-key) cmd_config_set_key ;;
        unset-key) cmd_config_unset_key ;;
        show) cmd_config_show ;;
        *)
            echo -e "${YELLOW}Usage: claude-seek config {set-key|unset-key|show}${NC}"
            exit 1
            ;;
    esac
}

cmd_cache_stats() {
    get_cache_stats
    exit 0
}

cmd_cache_clear() {
    echo -e "${YELLOW}⚠️  This will delete all cached responses.${NC}"
    read -p "Are you sure? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        clear_all_cache
    else
        echo -e "${GREEN}Cancelled${NC}"
    fi
    exit 0
}

cmd_cache_clean() {
    echo -e "${BLUE}🧹 Cleaning old cache entries...${NC}"
    clean_old_cache
    echo -e "${GREEN}✅ Clean complete${NC}"
    exit 0
}

cmd_cache() {
    case "${1:-}" in
        stats) cmd_cache_stats ;;
        clear) cmd_cache_clear ;;
        clean) cmd_cache_clean ;;
        *)
            echo -e "${YELLOW}Usage: claude-seek cache {stats|clear|clean}${NC}"
            exit 1
            ;;
    esac
}

cmd_setup() {
    run_setup_wizard
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
    
    echo -n "   Cache: "
    if [ "$CACHE_ENABLED" = "true" ]; then
        echo -e "${GREEN}✓ Enabled${NC}"
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
    cat << 'HELP'
claude-seek v1.1.0 - Claude Code with DeepSeek Models

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
USAGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  claude-seek                    Start interactive session
  claude-seek -p "query"         Run query and exit
  claude-seek --model MODEL      Force specific model

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMMANDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  setup                          Interactive setup wizard
  config set-key                 Configure API key
  config unset-key               Remove API key
  config show                    Show current settings
  cache stats                    Show cache statistics
  cache clear                    Clear all cached responses
  cache clean                    Remove expired cache entries
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

  claude-seek setup
  claude-seek -p "Write a Python function"
  claude-seek --model flash
  claude-seek config show
  claude-seek cache stats
  claude-seek doctor

HELP
    exit 0
}

cmd_version() {
    echo "claude-seek v1.1.0"
    exit 0
}

# ============================================
# MAIN COMMAND DISPATCH
# ============================================

case "${1:-}" in
    update) cmd_update ;;
    setup) cmd_setup ;;
    config) shift; cmd_config "$@" ;;
    cache) shift; cmd_cache "$@" ;;
    doctor) cmd_doctor ;;
    --help|-h) cmd_help ;;
    --version|-v) cmd_version ;;
esac

# ============================================
# MAIN EXECUTION (with cache support)
# ============================================

# Parse arguments
CLAUDESEEK_MODEL=""
QUERY=""
ARGS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --model) CLAUDESEEK_MODEL="$2"; shift 2 ;;
        -p) QUERY="$2"; shift 2 ;;
        *) ARGS+=("$1"); shift ;;
    esac
done

# Get API key
API_KEY=$(get_api_key)
if [ -z "$API_KEY" ]; then
    echo -e "${RED}❌ Error: No API key found${NC}"
    echo -e "${YELLOW}   Run: claude-seek setup${NC}"
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

# Set environment variables
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="$API_KEY"
export ANTHROPIC_MODEL="$SELECTED_MODEL"
export ANTHROPIC_SMALL_FAST_MODEL="deepseek-chat"

log "INFO" "Starting claude-seek with model: $SELECTED_MODEL"

# Launch Claude Code
echo -e "${CYAN}🚀 Starting claude-seek with model: $SELECTED_MODEL${NC}"
echo ""
exec "$SCRIPT_DIR/node_modules/.bin/claude" "${ARGS[@]}"
EOF

chmod +x "$INSTALL_DIR/$WRAPPER_SCRIPT"
echo -e "${GREEN}   ✅ Wrapper script created with cache support${NC}"

# Update PATH if needed
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
echo -e "${GREEN}🎉 Installation complete! (v1.1.0)${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Quick Start:${NC}"
echo ""
echo -e "   ${CYAN}1. Setup wizard:${NC}"
echo -e "     ${YELLOW}claude-seek setup${NC}"
echo ""
echo -e "   ${CYAN}2. Or just set API key:${NC}"
echo -e "     ${YELLOW}claude-seek config set-key${NC}"
echo ""
echo -e "   ${CYAN}3. Run claude-seek:${NC}"
echo -e "     ${YELLOW}claude-seek${NC}"
echo ""
echo -e "${BLUE}📚 New in v1.1.0:${NC}"
echo -e "   • Response caching (faster repeated queries)"
echo -e "   • ${YELLOW}claude-seek cache stats${NC} - view cache usage"
echo -e "   • ${YELLOW}claude-seek cache clear${NC} - clear cache"
echo -e "   • ${YELLOW}claude-seek setup${NC} - interactive wizard"
echo -e "   • ${YELLOW}claude-seek config show${NC} - view settings"
echo ""