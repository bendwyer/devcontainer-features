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
binary_name="age"
owner_name="FiloSottile"
repo_name="age"

arch=$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')

echo "Checking if ${binary_name} is installed..."
if [ "${VERSION}" = "none" ] || type ${binary_name} > /dev/null 2>&1; then
    echo "${binary_name} already installed. Skipping..."
else
  echo "Installing ${binary_name}..."
  if [ "${VERSION}" = "latest" ] ; then
    binary_version=$(curl -sSL https://api.github.com/repos/${owner_name}/${repo_name}/releases/latest | jq -r '.tag_name | split("v")[1]')
  else
    binary_version="${VERSION}"
  fi
  # curl -sSL https://github.com/${owner_name}/${repo_name}/releases/download/v${binary_version}/${binary_name}-v${binary_version}-linux-${arch}.tar.gz | tar xzf - -C /usr/local/bin/ ${binary_name}/${binary_name} ${binary_name}/age-inspect ${binary_name}/age-keygen ${binary_name}/age-plugin-batchpass
  tmp_dir=$(mktemp -d)
  curl -sSL https://github.com/${owner_name}/${repo_name}/releases/download/v${binary_version}/${binary_name}-v${binary_version}-linux-${arch}.tar.gz | tar xzf - -C "${tmp_dir}"
  mv "${tmp_dir}/${binary_name}"/age* /usr/local/bin/
  rm -rf "${tmp_dir}"
fi

set +e

echo "${binary_name} installation complete!"
