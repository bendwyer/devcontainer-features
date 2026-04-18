#!/usr/bin/env bash

set -e

REQUIRED_PACKAGES=(bash-completion curl jq)

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
binary_name="sops"
owner_name="getsops"
repo_name="sops"

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
  curl -sSL https://github.com/${owner_name}/${repo_name}/releases/download/v${binary_version}/${binary_name}-v${binary_version}.linux.${arch} -o /usr/local/bin/${binary_name} && chmod +x /usr/local/bin/${binary_name}
fi

echo "Installing bash completion for ${binary_name}..."
cat > /etc/profile.d/${binary_name}-completion.sh <<EOF
if [ -r /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi
if command -v ${binary_name} > /dev/null 2>&1; then
    source <(${binary_name} completion bash)
fi
EOF
chmod +x /etc/profile.d/${binary_name}-completion.sh
echo "Bash completion for ${binary_name} installed."

set +e

echo "${binary_name} installation complete!"
