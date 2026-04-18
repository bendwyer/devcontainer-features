#!/usr/bin/env bash

set -e

if ! command -v npm > /dev/null 2>&1; then
    echo "ERROR: npm not found. This feature requires the 'node' devcontainer feature." >&2
    echo "See: https://github.com/devcontainers/features/tree/main/src/node" >&2
    exit 1
fi

VERSION="${VERSION:-latest}"

npm install -g @ansible/ansible-mcp-server@$VERSION
