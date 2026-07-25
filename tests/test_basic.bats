#!/usr/bin/env bats

# ── File existence ────────────────────────────────────────────────────────────

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

@test "package.json exists" {
    [ -f "package.json" ]
}

# ── CLI availability ──────────────────────────────────────────────────────────

@test "claude-seek command is available" {
    run command -v claude-seek
    [ "$status" -eq 0 ]
}

# ── Version and help ──────────────────────────────────────────────────────────

@test "claude-seek --help exits 0" {
    run claude-seek --help
    [ "$status" -eq 0 ]
}

@test "claude-seek --help contains usage section" {
    run claude-seek --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
}

@test "claude-seek -h is alias for --help" {
    run claude-seek -h
    [ "$status" -eq 0 ]
}

@test "claude-seek --version exits 0" {
    run claude-seek --version
    [ "$status" -eq 0 ]
}

@test "claude-seek --version outputs version string" {
    run claude-seek --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude-seek v"* ]]
}

@test "claude-seek -v is alias for --version" {
    run claude-seek -v
    [ "$status" -eq 0 ]
}

# ── Version consistency ───────────────────────────────────────────────────────

@test "package.json and --version report the same version" {
    pkg_version=$(node -p "require('./package.json').version" 2>/dev/null || echo "unknown")
    run claude-seek --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"$pkg_version"* ]]
}

# ── Config commands (no API key needed) ──────────────────────────────────────

@test "claude-seek config show exits 0" {
    run claude-seek config show
    [ "$status" -eq 0 ]
}

@test "claude-seek config show contains History field" {
    run claude-seek config show
    [ "$status" -eq 0 ]
    [[ "$output" == *"History"* ]]
}

@test "claude-seek config with unknown subcommand exits non-zero" {
    run claude-seek config unknownsubcmd
    [ "$status" -ne 0 ]
}

# ── History commands (no API key needed) ─────────────────────────────────────

@test "claude-seek history list exits 0" {
    run claude-seek history list
    [ "$status" -eq 0 ]
}

@test "claude-seek history clear exits 0" {
    run claude-seek history clear
    [ "$status" -eq 0 ]
}

@test "claude-seek history show with invalid id exits non-zero" {
    run claude-seek history show nonexistent_session_id_xyz
    [ "$status" -ne 0 ]
}

@test "claude-seek history with unknown subcommand exits non-zero" {
    run claude-seek history unknownsubcmd
    [ "$status" -ne 0 ]
}

# ── Doctor ────────────────────────────────────────────────────────────────────

@test "claude-seek doctor exits 0" {
    run claude-seek doctor
    [ "$status" -eq 0 ]
}

@test "claude-seek doctor shows Node.js info" {
    run claude-seek doctor
    [ "$status" -eq 0 ]
    [[ "$output" == *"Node.js"* ]]
}

# ── No API key behavior ───────────────────────────────────────────────────────

@test "claude-seek without API key exits non-zero" {
    original_key="${DEEPSEEK_API_KEY:-}"
    unset DEEPSEEK_API_KEY
    tmp_key="$HOME/.claude-seek/key"
    tmp_backup=""
    if [ -f "$tmp_key" ]; then
        tmp_backup=$(mktemp)
        cp "$tmp_key" "$tmp_backup"
        rm -f "$tmp_key"
    fi

    run claude-seek
    status_code="$status"

    [ -n "$tmp_backup" ] && mv "$tmp_backup" "$tmp_key"
    [ -n "$original_key" ] && export DEEPSEEK_API_KEY="$original_key"

    [ "$status_code" -ne 0 ]
}

@test "claude-seek without API key shows actionable error message" {
    original_key="${DEEPSEEK_API_KEY:-}"
    unset DEEPSEEK_API_KEY
    tmp_key="$HOME/.claude-seek/key"
    tmp_backup=""
    if [ -f "$tmp_key" ]; then
        tmp_backup=$(mktemp)
        cp "$tmp_key" "$tmp_backup"
        rm -f "$tmp_key"
    fi

    run claude-seek
    output_text="$output"

    [ -n "$tmp_backup" ] && mv "$tmp_backup" "$tmp_key"
    [ -n "$original_key" ] && export DEEPSEEK_API_KEY="$original_key"

    [[ "$output_text" == *"setup"* ]] || [[ "$output_text" == *"API key"* ]]
}
