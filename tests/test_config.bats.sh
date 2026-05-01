#!/usr/bin/env bats

load helpers/test_helper

setup() {
    setup_helper
    install_claude_seek
}

@test "config set-key saves API key" {
    save_test_key
    [ -f "$HOME/.claude-seek/key" ]
}

@test "config show displays settings" {
    create_config "true" "auto" "false"
    run_claude_seek config show
    
    assert_contains "$output" "History: Enabled"
    assert_contains "$output" "Default Model: auto"
    assert_contains "$output" "Color Output: Enabled"
}

@test "config show with colors disabled" {
    create_config "true" "auto" "true"
    run_claude_seek config show
    
    assert_contains "$output" "Color Output: Disabled"
}

@test "config unset-key removes API key" {
    save_test_key
    [ -f "$HOME/.claude-seek/key" ]
    
    run_claude_seek config unset-key
    [ ! -f "$HOME/.claude-seek/key" ]
}

@test "config set-key validates key before saving" {
    skip "Requires real API key for validation"
}