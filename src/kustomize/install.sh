#!/usr/bin/env bash

set -e

REQUIRED_PACKAGES=(ca-certificates curl jq)

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

VERSION="${VERSION:-latest}"
binary_name="kustomize"
owner_name="kubernetes-sigs"
repo_name="kustomize"

arch=$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')

echo "Checking if ${binary_name} is installed..."
if [ "${VERSION}" = "none" ] || type ${binary_name} > /dev/null 2>&1; then
    echo "${binary_name} already installed. Skipping..."
else
  echo "Installing ${binary_name}..."
  if [ "${VERSION}" = "latest" ] ; then
    binary_tag=$(curl -sSL "https://api.github.com/repos/${owner_name}/${repo_name}/releases?per_page=30" | jq -r '[.[] | select(.tag_name | startswith("kustomize/"))][0].tag_name')
  else
    binary_tag="kustomize/v${VERSION}"
  fi
  binary_version="${binary_tag#kustomize/v}"
  curl -sSL https://github.com/${owner_name}/${repo_name}/releases/download/${binary_tag}/${binary_name}_v${binary_version}_linux_${arch}.tar.gz | tar xzf - -C /usr/local/bin/ ${binary_name}
fi

set +e

echo "${binary_name} installation complete!"
