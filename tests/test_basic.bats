#!/usr/bin/env bats

@test "install-claude-seek.sh exists" {
    [ -f "install-claude-seek.sh" ]
}

@test "uninstall-claude-seek.sh exists" {
    [ -f "uninstall-claude-seek.sh" ]
}

@test "LICENSE exists" {
    [ -f "LICENSE" ]
}

@test ".gitignore exists" {
    [ -f ".gitignore" ]
}

@test "claude-seek command is available" {
    run command -v claude-seek
    [ $status -eq 0 ]
}

@test "claude-seek --help works" {
    run claude-seek --help
    [ $status -eq 0 ]
}

@test "claude-seek --version works" {
    run claude-seek --version
    [ $status -eq 0 ]
}

@test "claude-seek doctor works" {
    run claude-seek doctor
    [ $status -eq 0 ]
}
