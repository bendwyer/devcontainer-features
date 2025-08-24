#!/usr/bin/env bash

set -e

KUBE_LINTER_VERSION=${VERSION:-"latest"}

if [ $(uname -m) = "aarch64" ] || [ $(uname -m) = "arm64" ]; then
  KUBE_LINTER_ARCH="_arm64"
else
  KUBE_LINTER_ARCH=""
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

echo "Checking if kube-linter is installed..."
if [ "${KUBE_LINTER_VERSION}" = "none" ] || type kube-linter > /dev/null 2>&1; then
    echo "kube-linter already installed. Skipping..."
else
  echo "Installing kube-linter..."
  if [ "${KUBE_LINTER_VERSION}" = "latest" ] ; then
    curl -sSL https://github.com/stackrox/kube-linter/releases/latest/download/kube-linter-linux${KUBE_LINTER_ARCH} -o /usr/local/bin/kube-linter && chmod +x /usr/local/bin/kube-linter
  else
    curl -sSL https://github.com/stackrox/kube-linter/releases/download/${KUBE_LINTER_VERSION}/kube-linter-linux${KUBE_LINTER_ARCH} -o /usr/local/bin/kube-linter && chmod +x /usr/local/bin/kube-linter
  fi
fi

set +e

echo "kube-linter installation complete!"
