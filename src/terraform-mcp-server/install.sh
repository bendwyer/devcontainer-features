#!/usr/bin/env bash

set -e

VERSION="${VERSION:-latest}"
feature_name="terraform-mcp-server"

if [ $(uname -m) = "aarch64" ] || [ $(uname -m) = "arm64" ]; then
  arch="arm64"
else
  arch="amd64"
fi

echo "Checking if ${feature_name} is installed..."
if [ "${VERSION}" = "none" ] || type ${feature_name} > /dev/null 2>&1; then
    echo "${feature_name} already installed. Skipping..."
else
  echo "Installing ${feature_name}..."
  if [ "${VERSION}" = "latest" ] ; then
    binary_version=$(curl -sSL https://api.github.com/repos/hashicorp/${feature_name}/releases/latest | jq -r '.tag_name | split("v")[1]')
  else
    binary_version="${VERSION}"
  fi
  curl -sSLO https://releases.hashicorp.com/${feature_name}/${binary_version}/${feature_name}_${binary_version}_linux_${arch}.zip && unzip -jq ${feature_name}_${binary_version}_linux_${arch}.zip ${feature_name} -d /usr/local/bin/
  rm -f ${feature_name}_${binary_version}_linux_${arch}.zip
fi

ls -la /usr/local/bin/${feature_name}
echo "${feature_name} installed successfully!"

set +e

echo "${feature_name} installation complete!"
