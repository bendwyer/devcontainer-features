#!/bin/bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# tflint specific tests
check "tflint" tflint --version

# Report result
reportResults
