#!/usr/bin/env bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# claude code specific tests
check "user" whoami
check " permissions" ls -la /usr/local/bin/kustomize
check "kustomize location" which kustomize
check "kustomize version" kustomize --version

# Report result
reportResults
