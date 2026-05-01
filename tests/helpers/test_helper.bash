# test_helper.bash - Helper functions for bats tests

setup() {
    # Create temporary test home
    export TEST_HOME="$(mktemp -d 2>/dev/null || mktemp -d -t 'claude-seek-test')"
    export HOME="$TEST_HOME"
    export TEST_DIR="$TEST_HOME/claude-seek-test"
    
    # Clear environment
    unset DEEPSEEK_API_KEY
    
    # Create test directory
    mkdir -p "$TEST_DIR"
}

teardown() {
    # Cleanup
    rm -rf "$TEST_HOME"
}

# Helper: Create mock API response
mock_api_response() {
    local status="${1:-success}"
    
    if [ "$status" = "success" ]; then
        echo '{"id":"test-123","type":"message","role":"assistant","content":[{"type":"text","text":"OK"}]}'
    else
        echo '{"error":{"message":"Invalid API key"}}'
    fi
}

# Helper: Mock curl command
mock_curl() {
    local response="$1"
    
    function curl() {
        echo "$response"
    }
    export -f curl
}

# Helper: Clear mocks
clear_mocks() {
    unset -f curl 2>/dev/null || true
}

# Helper: Install claude-seek
install_claude_seek() {
    cd "$TEST_DIR"
    cp -r "$BATS_TEST_DIRNAME/../.."/* . 2>/dev/null || true
    chmod +x install-claude-seek.sh
    ./install-claude-seek.sh
}

# Helper: Run claude-seek command
run_claude_seek() {
    export PATH="$HOME/.claude-seek:$PATH"
    run claude-seek "$@"
}

# Helper: Create config file
create_config() {
    local config_dir="$HOME/.claude-seek"
    mkdir -p "$config_dir"
    
    cat > "$config_dir/config.env" << EOF
HISTORY_ENABLED=${1:-true}
DEFAULT_MODEL=${2:-auto}
NO_COLOR=${3:-false}
EOF
}

# Helper: Save test API key
save_test_key() {
    local key="${1:-test_sk_1234567890}"
    local config_dir="$HOME/.claude-seek"
    mkdir -p "$config_dir"
    echo "$key" > "$config_dir/key"
    chmod 600 "$config_dir/key"
}

# Helper: Assert string contains substring
assert_contains() {
    local string="$1"
    local substring="$2"
    
    if [[ "$string" != *"$substring"* ]]; then
        echo "Expected: $string"
        echo "To contain: $substring"
        return 1
    fi
}