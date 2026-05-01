#!/usr/bin/env bats

load helpers/test_helper

setup() {
    setup_helper
    install_claude_seek
    save_test_key
    create_config "true" "auto" "false"
}

@test "history list shows empty when no sessions" {
    run_claude_seek history list
    assert_contains "$output" "No sessions found"
}

@test "history list shows sessions after runs" {
    # Simulate session creation
    mkdir -p "$HOME/.claude-seek/history"
    cat > "$HOME/.claude-seek/history/20250101_120000_12345.session" << EOF
SESSION_ID=20250101_120000_12345
START_DATE=Wed Jan 1 12:00:00 UTC 2025
PROJECT_DIR=/test/project
MODEL=deepseek-v4-pro
EOF
    
    run_claude_seek history list
    assert_contains "$output" "20250101_120000_12345"
}

@test "history show displays session details" {
    mkdir -p "$HOME/.claude-seek/history"
    cat > "$HOME/.claude-seek/history/test123.session" << EOF
SESSION_ID=test123
START_DATE=Wed Jan 1 12:00:00 UTC 2025
PROJECT_DIR=/test/project
MODEL=deepseek-v4-pro
COMMAND_1234567890="test query"
EOF
    
    run_claude_seek history show test123
    assert_contains "$output" "Session Details: test123"
    assert_contains "$output" "test query"
}

@test "history clear removes all sessions" {
    mkdir -p "$HOME/.claude-seek/history"
    echo "test" > "$HOME/.claude-seek/history/test.session"
    
    echo "y" | run_claude_seek history clear
    [ ! -f "$HOME/.claude-seek/history/test.session" ]
}

@test "history show shows error for invalid session" {
    run_claude_seek history show invalid_id
    assert_contains "$output" "Session not found"
}