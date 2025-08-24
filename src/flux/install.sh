#!/usr/bin/env bash

# Original script: https://github.com/goldsam/dev-container-features/blob/5919dade65b1c47d6fbd3aa13a62c938daeec4de/src/flux2/install.sh

set -e

FLUX_VERSION=${VERSION:-"latest"}

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

echo "Checking if flux is installed..."
if [ "${FLUX_VERSION}" = "none" ] || type flux > /dev/null 2>&1; then
    echo "flux already installed. Skipping..."
else
  echo "Installing flux..."
  if [ "${FLUX_VERSION}" = "latest" ] ; then
    curl -sS https://fluxcd.io/install.sh | bash
  else
    curl -sS https://fluxcd.io/install.sh | FLUX_VERSION=$FLUX_VERSION bash
  fi
fi

set +e

echo "flux installation complete!"
