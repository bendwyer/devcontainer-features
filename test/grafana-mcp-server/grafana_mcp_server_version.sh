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
check "grafana-mcp-server permissions" ls -la /usr/local/bin/mcp-grafana
check "grafana-mcp-server location" which mcp-grafana
check "grafana-mcp-server version" mcp-grafana --version

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
