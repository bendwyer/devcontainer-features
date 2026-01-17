#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
echo ""
echo "Running as $(whoami)"
# age
check "age permissions" ls -la /usr/local/bin/age
check "age location" which age
check "age version" age --version
# age-inspect
check "age-inspect permissions" ls -la /usr/local/bin/age-inspect
check "age-inspect location" which age-inspect
check "age-inspect version" age-inspect --version
# age-keygen
check "age-keygen permissions" ls -la /usr/local/bin/age-keygen
check "age-keygen location" which age-keygen
check "age-keygen version" age-keygen --version
# age-plugin-batchpass
check "age-plugin-batchpass permissions" ls -la /usr/local/bin/age-plugin-batchpass
check "age-plugin-batchpass location" which age-plugin-batchpass
check "age-plugin-batchpass version" age-plugin-batchpass --version

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
