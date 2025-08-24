#!/usr/bin/env bash

set -e

FLUX_MCP_SERVER_VERSION=${VERSION:-"latest"}

if [ $(uname -m) = "aarch64" ] || [ $(uname -m) = "arm64" ]; then
  FLUX_MCP_SERVER_ARCH="arm64"
else
  FLUX_MCP_SERVER_ARCH="amd64"
fi

export DEBIAN_FRONTEND=noninteractive

echo "Checking if curl is installed..."
if type curl > /dev/null 2>&1; then
    echo "curl already installed. Skipping..."
else
  echo "Installing curl..."
  apt-get -yq update
  apt-get -yq install curl
  echo "curl installation complete!"
fi

echo "Checking if flux mcp server is installed..."
if [ "${FLUX_MCP_SERVER_VERSION}" = "none" ] || type flux-operator-mcp > /dev/null 2>&1; then
    echo "flux mcp server already installed. Skipping..."
else
  echo "Installing flux mcp server..."
  if [ "${FLUX_MCP_SERVER_VERSION}" = "latest" ] ; then
    FLUX_MCP_SERVER_RELEASE=$(curl -sL https://api.github.com/repos/controlplaneio-fluxcd/flux-operator/releases/latest | jq -r '.tag_name | split("v")[1]')
    curl -sL https://github.com/controlplaneio-fluxcd/flux-operator/releases/latest/download/flux-operator-mcp_${FLUX_MCP_SERVER_RELEASE}_linux_${FLUX_MCP_SERVER_ARCH}.tar.gz | tar xzf - -C /usr/local/bin/ flux-operator-mcp
  else
    curl -sL https://github.com/controlplaneio-fluxcd/flux-operator/releases/download/v${FLUX_MCP_SERVER_VERSION}/flux-operator-mcp_${FLUX_MCP_SERVER_VERSION}_linux_${FLUX_MCP_SERVER_ARCH}.tar.gz | tar xzf - -C /usr/local/bin/ flux-operator-mcp
  fi
fi

set +e

echo "flux mcp server installation complete!"
