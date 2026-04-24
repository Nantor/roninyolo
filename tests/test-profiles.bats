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
    [ -f profiles/opencode/profile.sh ]
}

@test "default profile is opencode in help output" {
    run ./bin/roninyolo help
    [[ "$output" == *"opencode (default)"* ]]
}

# ── load_profile uses conditional assignment ───────────────

@test "opencode profile sets RY_IMAGE with conditional assignment" {
    run grep 'RY_IMAGE=.*${RY_IMAGE:-' profiles/opencode/profile.sh
    [ "$status" -eq 0 ]
}

@test "opencode profile sets RY_HOST_CONFIG_DIR with conditional assignment" {
    run grep 'RY_HOST_CONFIG_DIR=.*${RY_HOST_CONFIG_DIR:-' profiles/opencode/profile.sh
    [ "$status" -eq 0 ]
}

@test "opencode profile sets RY_CONTAINER_CONFIG_DIR with conditional assignment" {
    run grep 'RY_CONTAINER_CONFIG_DIR=.*${RY_CONTAINER_CONFIG_DIR:-' profiles/opencode/profile.sh
    [ "$status" -eq 0 ]
}

@test "opencode profile sets RY_DEFAULT_CMD conditionally" {
    run grep 'RY_DEFAULT_CMD' profiles/opencode/profile.sh
    [ "$status" -eq 0 ]
}

@test "opencode profile has a co-located Dockerfile" {
    [ -f profiles/opencode/Dockerfile ]
}

@test "opencode profile wires RY_DOCKERFILE to co-located Dockerfile" {
    run grep 'RY_DOCKERFILE=.*${RY_DOCKERFILE:-' profiles/opencode/profile.sh
    [ "$status" -eq 0 ]
}

@test "opencode profile sets RY_PROFILE_DIR correctly" {
    # Set up a mock environment to test RY_PROFILE_DIR
    cd "$BATS_TEST_DIRNAME/.."
    run bash -c '
        # Initialize all profile variables
        RY_AGENT_PROFILE="opencode"
        RY_PROFILE_DIR=""
        
        # Simulate what load_profile does by setting RY_PROFILE_DIR and sourcing the profile
        RY_PROFILE_DIR="$(pwd)/profiles/opencode"
        . profiles/opencode/profile.sh
        
        # Check that the Dockerfile path in RY_DOCKERFILE contains the profile dir path
        echo "$RY_DOCKERFILE"
    '
    [ "$status" -eq 0 ]
    [[ "$output" == *"profiles/opencode/Dockerfile"* ]]
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
        RY_DOCKERFILE=""
        RY_BUILD_CONTEXT=""
        RY_AGENT_PROFILE="opencode"

        # Source the project config (sets RY_IMAGE)
        . "'"$TEST_TMPDIR/proj/.roninyolo.conf"'"

        # Source the profile (should NOT overwrite RY_IMAGE)
        RY_PROFILE_DIR="'"$BATS_TEST_DIRNAME/../profiles/opencode"'"
        . "'"$BATS_TEST_DIRNAME/../profiles/opencode/profile.sh"'"

        echo "$RY_IMAGE"
    '
    [ "$status" -eq 0 ]
    [ "$output" = "custom-image:latest" ]
}

# ── aider profile ──────────────────────────────────────────

@test "bundled aider profile exists" {
    [ -f profiles/aider/profile.sh ]
}

@test "aider profile sets RY_IMAGE with conditional assignment" {
    run grep 'RY_IMAGE=.*${RY_IMAGE:-' profiles/aider/profile.sh
    [ "$status" -eq 0 ]
}

@test "aider profile sets RY_HOST_CONFIG_DIR with conditional assignment" {
    run grep 'RY_HOST_CONFIG_DIR=.*${RY_HOST_CONFIG_DIR:-' profiles/aider/profile.sh
    [ "$status" -eq 0 ]
}

@test "aider profile sets RY_CONTAINER_CONFIG_DIR with conditional assignment" {
    run grep 'RY_CONTAINER_CONFIG_DIR=.*${RY_CONTAINER_CONFIG_DIR:-' profiles/aider/profile.sh
    [ "$status" -eq 0 ]
}

@test "aider profile sets RY_DEFAULT_CMD conditionally" {
    run grep 'RY_DEFAULT_CMD' profiles/aider/profile.sh
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
        RY_DOCKERFILE=""
        RY_BUILD_CONTEXT=""
        RY_AGENT_PROFILE="aider"

        . "'"$TEST_TMPDIR/proj/.roninyolo.conf"'"
        RY_PROFILE_DIR="'"$BATS_TEST_DIRNAME/../profiles/aider"'"
        . "'"$BATS_TEST_DIRNAME/../profiles/aider/profile.sh"'"

        echo "$RY_IMAGE"
    '
    [ "$status" -eq 0 ]
    [ "$output" = "my-aider:latest" ]
}

# ── claude profile ─────────────────────────────────────────

@test "bundled claude profile exists" {
    [ -f profiles/claude/profile.sh ]
}

@test "claude profile sets RY_IMAGE with conditional assignment" {
    run grep 'RY_IMAGE=.*${RY_IMAGE:-' profiles/claude/profile.sh
    [ "$status" -eq 0 ]
}

@test "claude profile sets RY_HOST_CONFIG_DIR with conditional assignment" {
    run grep 'RY_HOST_CONFIG_DIR=.*${RY_HOST_CONFIG_DIR:-' profiles/claude/profile.sh
    [ "$status" -eq 0 ]
}

@test "claude profile sets RY_CONTAINER_CONFIG_DIR with conditional assignment" {
    run grep 'RY_CONTAINER_CONFIG_DIR=.*${RY_CONTAINER_CONFIG_DIR:-' profiles/claude/profile.sh
    [ "$status" -eq 0 ]
}

@test "claude profile sets RY_DEFAULT_CMD conditionally" {
    run grep 'RY_DEFAULT_CMD' profiles/claude/profile.sh
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
        RY_DOCKERFILE=""
        RY_BUILD_CONTEXT=""
        RY_AGENT_PROFILE="claude"

        . "'"$TEST_TMPDIR/proj/.roninyolo.conf"'"
        RY_PROFILE_DIR="'"$BATS_TEST_DIRNAME/../profiles/claude"'"
        . "'"$BATS_TEST_DIRNAME/../profiles/claude/profile.sh"'"

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
    # Install a custom profile in the user config dir (subdirectory layout)
    local user_profile_dir="$TEST_TMPDIR/fake_home/.config/roninyolo/profiles/myagent"
    mkdir -p "$user_profile_dir"
    echo '# custom profile' > "$user_profile_dir/profile.sh"

    # Override HOME so the script finds our fake profile dir
    HOME="$TEST_TMPDIR/fake_home" run ./bin/roninyolo profiles
    [ "$status" -eq 0 ]
    [[ "$output" == *"myagent"* ]]
}

@test "profiles subcommand is documented in help" {
    run ./bin/roninyolo help
    [[ "$output" == *"profiles"* ]]
}
