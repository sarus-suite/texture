#!/bin/bash

function setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    TEST_HELPER_DIR=$(readlink -f "$DIR/../../test/test_helper")
    load "${TEST_HELPER_DIR}/bats-support/load"
    load "${TEST_HELPER_DIR}/bats-assert/load"
    TMP_DIR=$(readlink -f "$DIR/../..")
    bats_require_minimum_version 1.5.0
}

function log() {
    echo "${@}" >&2
}

function logf() {
    printf "${@}\n" >&2
}
