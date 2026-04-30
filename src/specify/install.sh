#!/usr/bin/env bash

set -e

REQUIRED_PACKAGES=(git)

to_install=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    dpkg -s "$pkg" > /dev/null 2>&1 || to_install+=("$pkg")
done

if (( ${#to_install[@]} > 0 )); then
    echo "Installing missing packages: ${to_install[*]}"
    apt-get update
    apt-get install -y --no-install-recommends "${to_install[@]}"
    rm -rf /var/lib/apt/lists/*
fi

if ! command -v pipx > /dev/null 2>&1; then
    echo "ERROR: pipx not found. This feature requires the 'python' devcontainer feature with pipx tooling." >&2
    echo "See: https://github.com/devcontainers/features/tree/main/src/python" >&2
    exit 1
fi

VERSION="${VERSION:-latest}"
package_name="spec-kit"

if [ "${VERSION}" = "latest" ]; then
  pipx install "git+https://github.com/github/${package_name}.git"
else
  pipx install "git+https://github.com/github/${package_name}.git@v${VERSION}"
fi

echo "${package_name} installation complete!"
