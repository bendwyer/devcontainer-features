#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "user" whoami
check "aws cli location" which aws
check "aws cli version" aws --version
check "aws config dir exists" ls -ld /var/lib/aws
check "aws config dir is writable" bash -c "test -w /var/lib/aws && echo writable"
check "aws config symlink exists" bash -c "test -L ~/.aws && readlink ~/.aws | grep /var/lib/aws"
check "volume is mounted" bash -c "mount | grep /var/lib/aws"
# Report result
reportResults
