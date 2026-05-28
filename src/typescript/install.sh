#!/usr/bin/env bash

set -e

if ! command -v node > /dev/null 2>&1; then
    echo "ERROR: node not found. This feature requires the 'node' devcontainer feature." >&2
    echo "See: https://github.com/devcontainers/features/tree/main/src/node" >&2
    exit 1
fi

VERSION="${VERSION:-latest}"
package_name="typescript"

npm install -g ${package_name}@${VERSION}

echo "${package_name} feature installation complete!"
