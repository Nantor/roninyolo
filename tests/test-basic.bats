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
    [ "$output" = *"roninyolo"* ]
}

@test "roninyolo displays version" {
    run ./bin/roninyolo --version
    [ "$status" -eq 0 ]
    [ "$output" = *"roninyolo"* ]
}

@test "roninyolo init creates project" {
    run ./bin/roninyolo init test-project
    [ "$status" -eq 0 ]
    [ -f "test-project/.roninyolo.conf" ]
    rm -rf test-project
}

@test "roninyolo build fails without Dockerfile" {
    run ./bin/roninyolo build
    [ "$status" -ne 0 ]
}
