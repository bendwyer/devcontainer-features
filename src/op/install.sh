#!/usr/bin/env bash

set -e

VERSION="${VERSION:-latest}"
binary_name="op"

arch=$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')

echo "Checking if ${binary_name} is installed..."
if [ "${VERSION}" = "none" ] || type ${binary_name} > /dev/null 2>&1; then
    echo "${binary_name} already installed. Skipping..."
else
  echo "Installing ${binary_name}..."
  if [ "${VERSION}" = "latest" ] ; then
    binary_version=$(curl -sSL https://releases.1password.com/developers/cli/index.xml | grep -oP '<title>1Password CLI \K[0-9.]+' | tail -n1)
  else
    binary_version="${VERSION}"
  fi
  curl -sSLO https://cache.agilebits.com/dist/1P/op2/pkg/v${binary_version}/${binary_name}_linux_${arch}_v${binary_version}.zip && unzip -jq ${binary_name}_linux_${arch}_v${binary_version}.zip ${binary_name} -d /usr/local/bin/
  rm -f ${binary_name}_linux_${arch}_v${binary_version}.zip
fi

set +e

echo "${binary_name} installation complete!"
