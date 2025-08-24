#!/usr/bin/env bash

set -e

KUSTOMIZE_VERSION=${VERSION:-"latest"}

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

echo "Checking if kustomize is installed..."
if [ "${KUSTOMIZE_VERSION}" = "none" ] || type kustomize > /dev/null 2>&1; then
    echo "kustomize already installed. Skipping..."
else
  echo "Installing kustomize..."
  if [ "${KUSTOMIZE_VERSION}" = "latest" ] ; then
    curl -sS https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash -s -- /usr/local/bin
  else
    curl -sS https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash -s -- $KUSTOMIZE_VERSION /usr/local/bin
  fi
fi

set +e

echo "kustomize installation complete!"
