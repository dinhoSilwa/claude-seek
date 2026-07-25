#!/usr/bin/env bats

# ── File existence ────────────────────────────────────────────────────────────

@test "install-orion.sh exists" {
    [ -f "install-orion.sh" ]
}

@test "uninstall-orion.sh exists" {
    [ -f "uninstall-orion.sh" ]
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

@test "orion command is available" {
    run command -v orion
    [ "$status" -eq 0 ]
}

# ── Version and help ──────────────────────────────────────────────────────────

@test "orion --help exits 0" {
    run orion --help
    [ "$status" -eq 0 ]
}

@test "orion --help contains usage section" {
    run orion --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
}

@test "orion -h is alias for --help" {
    run orion -h
    [ "$status" -eq 0 ]
}

@test "orion --version exits 0" {
    run orion --version
    [ "$status" -eq 0 ]
}

@test "orion --version outputs version string" {
    run orion --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"orion v"* ]]
}

@test "orion -v is alias for --version" {
    run orion -v
    [ "$status" -eq 0 ]
}

# ── Version consistency ───────────────────────────────────────────────────────

@test "package.json and --version report the same version" {
    pkg_version=$(node -p "require('./package.json').version" 2>/dev/null || echo "unknown")
    run orion --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"$pkg_version"* ]]
}

# ── Config commands (no API key needed) ──────────────────────────────────────

@test "orion config show exits 0" {
    run orion config show
    [ "$status" -eq 0 ]
}

@test "orion config show contains History field" {
    run orion config show
    [ "$status" -eq 0 ]
    [[ "$output" == *"History"* ]]
}

@test "orion config with unknown subcommand exits non-zero" {
    run orion config unknownsubcmd
    [ "$status" -ne 0 ]
}

# ── History commands (no API key needed) ─────────────────────────────────────

@test "orion history list exits 0" {
    run orion history list
    [ "$status" -eq 0 ]
}

@test "orion history clear exits 0" {
    run orion history clear
    [ "$status" -eq 0 ]
}

@test "orion history show with invalid id exits non-zero" {
    run orion history show nonexistent_session_id_xyz
    [ "$status" -ne 0 ]
}

@test "orion history with unknown subcommand exits non-zero" {
    run orion history unknownsubcmd
    [ "$status" -ne 0 ]
}

# ── Doctor ────────────────────────────────────────────────────────────────────

@test "orion doctor exits 0" {
    run orion doctor
    [ "$status" -eq 0 ]
}

@test "orion doctor shows Node.js info" {
    run orion doctor
    [ "$status" -eq 0 ]
    [[ "$output" == *"Node.js"* ]]
}

# ── No API key behavior ───────────────────────────────────────────────────────

@test "orion without API key exits non-zero" {
    original_key="${DEEPSEEK_API_KEY:-}"
    unset DEEPSEEK_API_KEY
    tmp_key="$HOME/.orion/key"
    tmp_backup=""
    if [ -f "$tmp_key" ]; then
        tmp_backup=$(mktemp)
        cp "$tmp_key" "$tmp_backup"
        rm -f "$tmp_key"
    fi

    run orion
    status_code="$status"

    [ -n "$tmp_backup" ] && mv "$tmp_backup" "$tmp_key"
    [ -n "$original_key" ] && export DEEPSEEK_API_KEY="$original_key"

    [ "$status_code" -ne 0 ]
}

@test "orion without API key shows actionable error message" {
    original_key="${DEEPSEEK_API_KEY:-}"
    unset DEEPSEEK_API_KEY
    tmp_key="$HOME/.orion/key"
    tmp_backup=""
    if [ -f "$tmp_key" ]; then
        tmp_backup=$(mktemp)
        cp "$tmp_key" "$tmp_backup"
        rm -f "$tmp_key"
    fi

    run orion
    output_text="$output"

    [ -n "$tmp_backup" ] && mv "$tmp_backup" "$tmp_key"
    [ -n "$original_key" ] && export DEEPSEEK_API_KEY="$original_key"

    [[ "$output_text" == *"setup"* ]] || [[ "$output_text" == *"API key"* ]]
}
