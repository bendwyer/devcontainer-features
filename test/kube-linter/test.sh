#!/usr/bin/env bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# claude code specific tests
check "user" whoami
check " permissions" ls -la /usr/local/bin/kube-linter
check "kube-linter location" which kube-linter
check "kube-linter version" kube-linter version

# Report result
reportResults
