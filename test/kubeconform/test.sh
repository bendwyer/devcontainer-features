#!/usr/bin/env bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# claude code specific tests
check "user" whoami
check " permissions" ls -la /usr/local/bin/kubeconform
check "kubeconform location" which kubeconform
check "kubeconform version" kubeconform -v

# Report result
reportResults
