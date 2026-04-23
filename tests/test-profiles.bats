#!/usr/bin/env bats
#
# Tests for the agent-profile loading mechanism
#

setup() {
    cd "$BATS_TEST_DIRNAME/.."
    TEST_TMPDIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_TMPDIR"
}

# ── bundled profile ────────────────────────────────────────

@test "bundled opencode profile exists" {
    [ -f profiles/opencode.sh ]
}

@test "default profile is opencode in help output" {
    run ./bin/roninyolo help
    [[ "$output" == *"opencode (default)"* ]]
}

# ── load_profile uses conditional assignment ───────────────

@test "opencode profile sets RY_BASE_IMAGE with conditional assignment" {
    run grep 'RY_BASE_IMAGE=.*{RY_BASE_IMAGE:-' profiles/opencode.sh
    [ "$status" -eq 0 ]
}

@test "opencode profile sets RY_IMAGE with conditional assignment" {
    # The profile should use ${RY_IMAGE:-...} so grep for the pattern
    run grep 'RY_IMAGE=.*{RY_IMAGE:-' profiles/opencode.sh
    [ "$status" -eq 0 ]
}

@test "opencode profile sets RY_HOST_CONFIG_DIR with conditional assignment" {
    run grep 'RY_HOST_CONFIG_DIR=.*{RY_HOST_CONFIG_DIR:-' profiles/opencode.sh
    [ "$status" -eq 0 ]
}

@test "opencode profile sets RY_CONTAINER_CONFIG_DIR with conditional assignment" {
    run grep 'RY_CONTAINER_CONFIG_DIR=.*{RY_CONTAINER_CONFIG_DIR:-' profiles/opencode.sh
    [ "$status" -eq 0 ]
}

@test "opencode profile sets RY_DEFAULT_CMD conditionally" {
    run grep 'RY_DEFAULT_CMD' profiles/opencode.sh
    [ "$status" -eq 0 ]
}

# ── init template includes RY_AGENT_PROFILE ────────────────

@test "init template contains RY_AGENT_PROFILE" {
    run ./bin/roninyolo init "$TEST_TMPDIR/proj"
    [ "$status" -eq 0 ]
    run grep 'RY_AGENT_PROFILE' "$TEST_TMPDIR/proj/.roninyolo.conf"
    [ "$status" -eq 0 ]
}

# ── missing profile produces an error ──────────────────────

@test "unknown profile name fails with error" {
    # Create a project config that sets a nonexistent profile
    mkdir -p "$TEST_TMPDIR/proj"
    echo 'RY_AGENT_PROFILE="nonexistent_profile_xyz"' > "$TEST_TMPDIR/proj/.roninyolo.conf"

    # Run from that directory so the .roninyolo.conf is picked up
    cd "$TEST_TMPDIR/proj"
    run "$BATS_TEST_DIRNAME/../bin/roninyolo" help
    [ "$status" -ne 0 ]
    [[ "$output" == *"profile 'nonexistent_profile_xyz' not found"* ]]
}

# ── user config wins over profile defaults ─────────────────

@test "user config overrides profile defaults for RY_IMAGE" {
    # Create a project config that sets RY_IMAGE before the profile runs
    mkdir -p "$TEST_TMPDIR/proj"
    echo 'RY_IMAGE="custom-image:latest"' > "$TEST_TMPDIR/proj/.roninyolo.conf"

    # Source the script's functions in a subshell to test the value
    cd "$TEST_TMPDIR/proj"
    run bash -c '
        # Replicate the load sequence: defaults -> config -> profile
        RY_IMAGE=""
        RY_HOST_CONFIG_DIR=""
        RY_CONTAINER_CONFIG_DIR=""
        RY_DEFAULT_CMD=()
        RY_AGENT_PROFILE="opencode"

        # Source the project config (sets RY_IMAGE)
        . "'"$TEST_TMPDIR/proj/.roninyolo.conf"'"

        # Source the profile (should NOT overwrite RY_IMAGE)
        . "'"$BATS_TEST_DIRNAME/../profiles/opencode.sh"'"

        echo "$RY_IMAGE"
    '
    [ "$status" -eq 0 ]
    [ "$output" = "custom-image:latest" ]
}

# ── aider profile ──────────────────────────────────────────

@test "bundled aider profile exists" {
    [ -f profiles/aider.sh ]
}

@test "aider profile sets RY_BASE_IMAGE with conditional assignment" {
    run grep 'RY_BASE_IMAGE=.*{RY_BASE_IMAGE:-' profiles/aider.sh
    [ "$status" -eq 0 ]
}

@test "aider profile sets RY_IMAGE with conditional assignment" {
    run grep 'RY_IMAGE=.*{RY_IMAGE:-' profiles/aider.sh
    [ "$status" -eq 0 ]
}

@test "aider profile sets RY_HOST_CONFIG_DIR with conditional assignment" {
    run grep 'RY_HOST_CONFIG_DIR=.*{RY_HOST_CONFIG_DIR:-' profiles/aider.sh
    [ "$status" -eq 0 ]
}

@test "aider profile sets RY_CONTAINER_CONFIG_DIR with conditional assignment" {
    run grep 'RY_CONTAINER_CONFIG_DIR=.*{RY_CONTAINER_CONFIG_DIR:-' profiles/aider.sh
    [ "$status" -eq 0 ]
}

@test "aider profile sets RY_DEFAULT_CMD conditionally" {
    run grep 'RY_DEFAULT_CMD' profiles/aider.sh
    [ "$status" -eq 0 ]
}

@test "aider profile listed in help output" {
    run ./bin/roninyolo help
    [[ "$output" == *"aider"* ]]
}

@test "user config overrides aider profile defaults for RY_IMAGE" {
    mkdir -p "$TEST_TMPDIR/proj"
    echo 'RY_IMAGE="my-aider:latest"' > "$TEST_TMPDIR/proj/.roninyolo.conf"

    cd "$TEST_TMPDIR/proj"
    run bash -c '
        RY_IMAGE=""
        RY_HOST_CONFIG_DIR=""
        RY_CONTAINER_CONFIG_DIR=""
        RY_DEFAULT_CMD=()
        RY_AGENT_PROFILE="aider"

        . "'"$TEST_TMPDIR/proj/.roninyolo.conf"'"
        . "'"$BATS_TEST_DIRNAME/../profiles/aider.sh"'"

        echo "$RY_IMAGE"
    '
    [ "$status" -eq 0 ]
    [ "$output" = "my-aider:latest" ]
}

# ── claude profile ─────────────────────────────────────────

@test "bundled claude profile exists" {
    [ -f profiles/claude.sh ]
}

@test "claude profile sets RY_BASE_IMAGE with conditional assignment" {
    run grep 'RY_BASE_IMAGE=.*{RY_BASE_IMAGE:-' profiles/claude.sh
    [ "$status" -eq 0 ]
}

@test "claude profile sets RY_IMAGE with conditional assignment" {
    run grep 'RY_IMAGE=.*{RY_IMAGE:-' profiles/claude.sh
    [ "$status" -eq 0 ]
}

@test "claude profile sets RY_HOST_CONFIG_DIR with conditional assignment" {
    run grep 'RY_HOST_CONFIG_DIR=.*{RY_HOST_CONFIG_DIR:-' profiles/claude.sh
    [ "$status" -eq 0 ]
}

@test "claude profile sets RY_CONTAINER_CONFIG_DIR with conditional assignment" {
    run grep 'RY_CONTAINER_CONFIG_DIR=.*{RY_CONTAINER_CONFIG_DIR:-' profiles/claude.sh
    [ "$status" -eq 0 ]
}

@test "claude profile sets RY_DEFAULT_CMD conditionally" {
    run grep 'RY_DEFAULT_CMD' profiles/claude.sh
    [ "$status" -eq 0 ]
}

@test "claude profile listed in help output" {
    run ./bin/roninyolo help
    [[ "$output" == *"claude"* ]]
}

@test "user config overrides claude profile defaults for RY_IMAGE" {
    mkdir -p "$TEST_TMPDIR/proj"
    echo 'RY_IMAGE="my-claude:latest"' > "$TEST_TMPDIR/proj/.roninyolo.conf"

    cd "$TEST_TMPDIR/proj"
    run bash -c '
        RY_IMAGE=""
        RY_HOST_CONFIG_DIR=""
        RY_CONTAINER_CONFIG_DIR=""
        RY_DEFAULT_CMD=()
        RY_AGENT_PROFILE="claude"

        . "'"$TEST_TMPDIR/proj/.roninyolo.conf"'"
        . "'"$BATS_TEST_DIRNAME/../profiles/claude.sh"'"

        echo "$RY_IMAGE"
    '
    [ "$status" -eq 0 ]
    [ "$output" = "my-claude:latest" ]
}

# ── profiles subcommand ───────────────────────────────────

@test "profiles subcommand exits successfully" {
    run ./bin/roninyolo profiles
    [ "$status" -eq 0 ]
}

@test "profiles subcommand lists opencode" {
    run ./bin/roninyolo profiles
    [[ "$output" == *"opencode"* ]]
}

@test "profiles subcommand lists aider" {
    run ./bin/roninyolo profiles
    [[ "$output" == *"aider"* ]]
}

@test "profiles subcommand lists claude" {
    run ./bin/roninyolo profiles
    [[ "$output" == *"claude"* ]]
}

@test "profiles subcommand marks default profile as active" {
    run ./bin/roninyolo profiles
    [[ "$output" == *"opencode (active)"* ]]
}

@test "profiles subcommand marks selected profile as active" {
    mkdir -p "$TEST_TMPDIR/proj"
    echo 'RY_AGENT_PROFILE="aider"' > "$TEST_TMPDIR/proj/.roninyolo.conf"

    cd "$TEST_TMPDIR/proj"
    run "$BATS_TEST_DIRNAME/../bin/roninyolo" profiles
    [ "$status" -eq 0 ]
    [[ "$output" == *"aider (active)"* ]]
}

@test "profiles subcommand does not mark non-active profile as active" {
    run ./bin/roninyolo profiles
    # aider should NOT be marked active when opencode is the default
    [[ "$output" != *"aider (active)"* ]]
}

@test "profiles subcommand discovers user-installed profiles" {
    # Install a custom profile in the user config dir
    local user_profile_dir="$TEST_TMPDIR/fake_home/.config/roninyolo/profiles"
    mkdir -p "$user_profile_dir"
    echo '# custom profile' > "$user_profile_dir/myagent.sh"

    # Override HOME so the script finds our fake profile dir
    HOME="$TEST_TMPDIR/fake_home" run ./bin/roninyolo profiles
    [ "$status" -eq 0 ]
    [[ "$output" == *"myagent"* ]]
}

@test "profiles subcommand is documented in help" {
    run ./bin/roninyolo help
    [[ "$output" == *"profiles"* ]]
}
