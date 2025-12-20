#!/usr/bin/env bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# claude code specific tests
check "user" whoami
check "claude code location" which claude
check "claude code version" claude --version

# Report result
reportResults
