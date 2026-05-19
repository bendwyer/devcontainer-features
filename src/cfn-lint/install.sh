#!/usr/bin/env bash

set -e

if ! command -v pipx > /dev/null 2>&1; then
    echo "ERROR: pipx not found. This feature requires the 'python' devcontainer feature with pipx tooling." >&2
    echo "See: https://github.com/devcontainers/features/tree/main/src/python" >&2
    exit 1
fi

VERSION="${VERSION:-latest}"
package_name="cfn-lint"

if [ "${VERSION}" = "latest" ]; then
  pipx install "${package_name}"
else
  pipx install "${package_name}"=="${VERSION}"
fi

echo "${package_name} feature installation complete!"
