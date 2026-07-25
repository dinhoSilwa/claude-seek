#!/usr/bin/env bats

HISTORY_DIR="$HOME/.orion/history"

setup() {
    mkdir -p "$HISTORY_DIR"
}

teardown() {
    rm -f "$HISTORY_DIR"/test_bats_*.session
}

# ── history list ──────────────────────────────────────────────────────────────

@test "history list exits 0 with no sessions" {
    run orion history list
    [ "$status" -eq 0 ]
}

@test "history list shows empty message when no sessions exist" {
    rm -f "$HISTORY_DIR"/*.session 2>/dev/null || true
    run orion history list
    [ "$status" -eq 0 ]
    [[ "$output" == *"No sessions found"* ]]
}

@test "history list shows session after it is created" {
    cat > "$HISTORY_DIR/test_bats_20250101_120000_99999.session" << EOF
SESSION_ID=test_bats_20250101_120000_99999
START_DATE=Wed Jan 1 12:00:00 UTC 2025
PROJECT_DIR=/test/project
MODEL=deepseek-v4-pro
EOF
    run orion history list
    [ "$status" -eq 0 ]
    [[ "$output" == *"test_bats_20250101"* ]]
}

# ── history show ──────────────────────────────────────────────────────────────

@test "history show exits non-zero for nonexistent session" {
    run orion history show nonexistent_bats_session_xyz
    [ "$status" -ne 0 ]
}

@test "history show displays session fields" {
    cat > "$HISTORY_DIR/test_bats_show.session" << EOF
SESSION_ID=test_bats_show
START_DATE=Wed Jan 1 12:00:00 UTC 2025
PROJECT_DIR=/test/project
MODEL=deepseek-v4-pro
EOF
    run orion history show test_bats_show
    [ "$status" -eq 0 ]
    [[ "$output" == *"test_bats_show"* ]]
}

# ── history clear ─────────────────────────────────────────────────────────────

@test "history clear exits 0" {
    run orion history clear
    [ "$status" -eq 0 ]
}

@test "history clear removes session files" {
    echo "dummy" > "$HISTORY_DIR/test_bats_clear.session"
    run orion history clear
    [ "$status" -eq 0 ]
    [ ! -f "$HISTORY_DIR/test_bats_clear.session" ]
}

@test "history list shows empty after clear" {
    echo "dummy" > "$HISTORY_DIR/test_bats_afterclear.session"
    orion history clear
    run orion history list
    [ "$status" -eq 0 ]
    [[ "$output" == *"No sessions found"* ]]
}

# ── history unknown subcommand ────────────────────────────────────────────────

@test "history unknown subcommand exits non-zero" {
    run orion history badcmd
    [ "$status" -ne 0 ]
}
