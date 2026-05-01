#!/usr/bin/env bats

load helpers/test_helper

@test "Installation script exists" {
    [ -f "install-claude-seek.sh" ]
}

@test "Installation script is executable" {
    [ -x "install-claude-seek.sh" ]
}

@test "Uninstall script exists" {
    [ -f "uninstall-claude-seek.sh" ]
}

@test "Installation creates .claude-seek directory" {
    skip "Requires actual installation"
}

@test "Wrapper script is created with correct permissions" {
    skip "Requires actual installation"
}

@test "PATH is updated in shell profile" {
    skip "Requires non-CI environment"
}