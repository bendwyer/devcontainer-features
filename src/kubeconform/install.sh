#!/usr/bin/env bash

set -e

KUBECONFORM_VERSION=${VERSION:-"latest"}

if [ $(uname -m) = "aarch64" ] || [ $(uname -m) = "arm64" ]; then
  KUBECONFORM_ARCH="arm64"
else
  KUBECONFORM_ARCH="amd64"
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

echo "Checking if kubeconform is installed..."
if [ "${KUBECONFORM_VERSION}" = "none" ] || type kubeconform > /dev/null 2>&1; then
    echo "kubeconform already installed. Skipping..."
else
  echo "Installing kubeconform..."
  if [ "${KUBECONFORM_VERSION}" = "latest" ] ; then
    curl -sL https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-${KUBECONFORM_ARCH}.tar.gz | tar xzf - -C /usr/local/bin/ kubeconform
  else
    curl -sL https://github.com/yannh/kubeconform/releases/download/${KUBECONFORM_VERSION}/kubeconform-linux-${KUBECONFORM_ARCH}.tar.gz | tar xzf - -C /usr/local/bin/ kubeconform
  fi
fi

set +e

echo "kubeconform installation complete!"
