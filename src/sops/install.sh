#!/usr/bin/env bash

set -e

REQUIRED_PACKAGES=(bash-completion ca-certificates curl jq sudo)

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

target_user="${_REMOTE_USER:-root}"
echo "Installing bash completion for ${binary_name} for ${target_user}..."
if [ "${target_user}" = "root" ]; then
    target_bashrc="/root/.bashrc"
else
    target_bashrc="/home/${target_user}/.bashrc"
fi
completion_marker="# ${binary_name} completion (managed by ${binary_name} devcontainer feature)"
if ! grep -qF "${completion_marker}" "${target_bashrc}" 2>/dev/null; then
    {
        echo ""
        echo "${completion_marker}"
        echo "source /usr/share/bash-completion/bash_completion"
        echo "source <(${binary_name} completion bash)"
    } >> "${target_bashrc}"
fi
chown "${target_user}:${target_user}" "${target_bashrc}" 2>/dev/null || true
echo "Bash completion for ${binary_name} installed."

set +e

echo "${binary_name} installation complete!"
