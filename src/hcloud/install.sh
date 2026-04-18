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
binary_name="hcloud"
owner_name="hetznercloud"
repo_name="cli"

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
  curl -sSL https://github.com/${owner_name}/${repo_name}/releases/download/v${binary_version}/${binary_name}-linux-${arch}.tar.gz | tar xzf - -C /usr/local/bin/ ${binary_name}
fi

target_user="${_REMOTE_USER:-root}"
echo "Installing bash completion for ${binary_name} for ${target_user}..."
if [ "${target_user}" = "root" ]; then
    target_home="/root"
else
    target_home="/home/${target_user}"
fi
target_bashrc="${target_home}/.bashrc"
mkdir -p "${target_home}"
if [ ! -s "${target_bashrc}" ]; then
    cp /etc/skel/.bashrc "${target_bashrc}" 2>/dev/null || touch "${target_bashrc}"
fi
completion_line="source <(${binary_name} completion bash)"
if ! grep -qF "${completion_line}" "${target_bashrc}" 2>/dev/null; then
    {
        echo ""
        echo "# ${binary_name} completion (managed by ${binary_name} devcontainer feature)"
        echo "${completion_line}"
    } >> "${target_bashrc}"
fi
chown "${target_user}:${target_user}" "${target_home}" "${target_bashrc}" 2>/dev/null || true
echo "Bash completion for ${binary_name} installed."

set +e

echo "${binary_name} installation complete!"
