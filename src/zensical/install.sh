#!/usr/bin/env bash

set -e

if ! command -v pipx > /dev/null 2>&1; then
    echo "ERROR: pipx not found. This feature requires the 'python' devcontainer feature with pipx tooling." >&2
    echo "See: https://github.com/devcontainers/features/tree/main/src/python" >&2
    exit 1
fi

VERSION="${VERSION:-latest}"
package_name="zensical"

if [ "${VERSION}" = "latest" ]; then
  pipx install "${package_name}" --include-deps
else
  pipx install "${package_name}"=="${VERSION}" --include-deps
fi

echo "${package_name} installation complete!"
