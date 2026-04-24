#!/usr/bin/env bats
#
# Basic tests for roninyolo
#

setup() {
    cd "$BATS_TEST_DIRNAME/.."
}

@test "roninyolo displays help" {
    run ./bin/roninyolo --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"roninyolo"* ]]
}

@test "roninyolo displays version" {
    run ./bin/roninyolo --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"roninyolo"* ]]
}

@test "roninyolo init creates project" {
    run ./bin/roninyolo init test-project
    [ "$status" -eq 0 ]
    [ -f "test-project/.roninyolo.conf" ]
    rm -rf test-project
}

@test "roninyolo build exits 0 with INFO when active profile uses a registry image" {
    # The aider and claude profiles use pre-built upstream images and provide no
    # Dockerfile, so do_build() should print an informational message and
    # exit successfully rather than erroring out.
    local tmpdir
    tmpdir="$(mktemp -d)"
    
    for profile in aider claude; do
        printf "RY_AGENT_PROFILE=\"%s\"\n" "$profile" > "$tmpdir/.roninyolo.conf"
        cd "$tmpdir"
        run "$BATS_TEST_DIRNAME/../bin/roninyolo" build
        [ "$status" -eq 0 ]
        [[ "$output" == *"registry image"* ]]
        cd "$BATS_TEST_DIRNAME/.."
    done
    
    rm -rf "$tmpdir"
}
