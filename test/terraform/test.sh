#!/bin/bash -i

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
echo ""
echo "Running as $(whoami)"
check "terraform permissions" ls -la /usr/local/bin/terraform
check "terraform location" which terraform
check "terraform version" terraform --version
check "terraform autocompletion" ./terraform_autocompletion.sh "terraform " "version"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
