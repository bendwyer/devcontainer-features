#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "user" whoami
check "gh cli location" which gh
check "gh cli version" gh --version
check "gh config dir exists" ls -ld /var/lib/gh
check "gh config dir is writable" bash -c "test -w /var/lib/gh && echo writable"
check "gh config symlink exists" bash -c "test -L ~/.config/gh && readlink ~/.config/gh | grep /var/lib/gh"
check "volume is mounted" bash -c "mount | grep /var/lib/gh"
# Report result
reportResults
