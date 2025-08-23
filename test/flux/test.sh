#!/usr/bin/env bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# claude code specific tests
check "user" whoami
check "flux permissions" ls -la /usr/local/bin/flux
check "flux location" which flux
check "flux version" flux --version

# Report result
reportResults
