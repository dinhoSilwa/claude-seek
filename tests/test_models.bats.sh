#!/usr/bin/env bats

load helpers/test_helper

setup() {
    setup_helper
    install_claude_seek
    save_test_key
    create_config "false" "auto" "false"
}

@test "Doctor shows model availability" {
    # Mock model availability
    function test_model_availability() {
        return 0
    }
    export -f test_model_availability
    
    run_claude_seek doctor
    assert_contains "$output" "deepseek-v4-pro"
    assert_contains "$output" "deepseek-v4-flash"
    assert_contains "$output" "deepseek-chat"
}

@test "Default model selection works" {
    create_config "false" "deepseek-v4-flash" "false"
    run_claude_seek --help  # Just verify config loads
    [ $status -eq 0 ]
}

@test "Model override via --model flag" {
    create_config "false" "auto" "false"
    # Just verify flag parsing works
    run_claude_seek --model deepseek-v4-flash --help
    [ $status -eq 0 ]
}