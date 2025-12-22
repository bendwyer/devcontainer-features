#!/usr/bin/env bash

set -e

VERSION="${VERSION:-latest}"
binary_name="flux-operator-mcp"

arch=$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')

echo "Checking if ${binary_name} is installed..."
if [ "${VERSION}" = "none" ] || type ${binary_name} > /dev/null 2>&1; then
    echo "${binary_name} already installed. Skipping..."
else
  echo "Installing ${binary_name}..."
  if [ "${VERSION}" = "latest" ] ; then
    binary_version=$(curl -sSL https://api.github.com/repos/controlplaneio-fluxcd/flux-operator/releases/latest | jq -r '.tag_name | split("v")[1]')
  else
    binary_version="${VERSION}"
  fi
  curl -sSL https://github.com/controlplaneio-fluxcd/flux-operator/releases/download/v${binary_version}/${binary_name}_${binary_version}_linux_${arch}.tar.gz | tar xzf - -C /usr/local/bin/ ${binary_name}
fi

set +e

echo "${binary_name} installation complete!"
