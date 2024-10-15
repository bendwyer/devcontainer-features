#!/bin/bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# Terraform version specific tests
check "terraform" terraform --version

# Report result
reportResults
