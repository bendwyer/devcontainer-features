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

VERSION="${VERSION:-stable}"
binary_name="claude"
gcs_bucket="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
install_dir="/usr/local/bin"
download_dir=$(mktemp -d)
trap 'rm -rf "${download_dir}"' EXIT

case "$(uname -m)" in
    x86_64|amd64)  arch="x64" ;;
    arm64|aarch64) arch="arm64" ;;
    *) echo "Error: unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

# Anthropic publishes separate musl builds
if [ -f /lib/libc.musl-x86_64.so.1 ] \
    || [ -f /lib/libc.musl-aarch64.so.1 ] \
    || ldd /bin/ls 2>&1 | grep -q musl; then
    platform="linux-${arch}-musl"
else
    platform="linux-${arch}"
fi

echo "Checking if ${binary_name} is installed..."
if [ "${VERSION}" = "none" ] || type ${binary_name} > /dev/null 2>&1; then
    echo "${binary_name} already installed. Skipping..."
else
    echo "Installing ${binary_name} for ${platform}..."
    if [ "${VERSION}" = "stable" ] || [ "${VERSION}" = "latest" ]; then
        binary_version=$(curl -fsSL "${gcs_bucket}/${VERSION}")
    else
        binary_version="${VERSION}"
    fi
    echo "Resolved version: ${binary_version}"

    manifest_json=$(curl -fsSL "${gcs_bucket}/${binary_version}/manifest.json")
    checksum=$(echo "${manifest_json}" | jq -r ".platforms[\"${platform}\"].checksum // empty")

    if [ -z "${checksum}" ] || [[ ! "${checksum}" =~ ^[a-f0-9]{64}$ ]]; then
        echo "Error: platform ${platform} not found in manifest" >&2
        exit 1
    fi

    binary_path="${download_dir}/${binary_name}"
    curl -fsSL -o "${binary_path}" "${gcs_bucket}/${binary_version}/${platform}/${binary_name}"

    actual=$(sha256sum "${binary_path}" | cut -d' ' -f1)
    if [ "${actual}" != "${checksum}" ]; then
        echo "Error: checksum verification failed" >&2
        exit 1
    fi

    chmod +x "${binary_path}"
    mv "${binary_path}" "${install_dir}/${binary_name}"
    echo "$binary_version" > /usr/local/share/claude-version
fi

# Prepare the CLAUDE_CONFIG_DIR mount point.
# Mode 1777 (sticky bit) is used instead of chown because devcontainer runtimes
# may re-map the target user's UID at runtime (updateRemoteUserUID), which would
# leave a build-time chown pointing at the wrong UID. Sticky bit lets any user
# write while preventing deletion of other users' files. Individual files claude
# writes get 600 perms from claude itself.
target_user="${_REMOTE_USER:-root}"
if [ "${target_user}" = "root" ]; then
    target_home="/root"
else
    target_home="/home/${target_user}"
fi
mounted_dir="/var/lib/claude"
config_dir="${target_home}/.claude"

mkdir -p "${mounted_dir}/ide"
chmod 1777 "${mounted_dir}"
chmod 1777 "${mounted_dir}/ide"

# Symlink ~/.claude/ide -> /var/lib/claude/ide so consumers that read the path
# literally (e.g., the VS Code extension IDE MCP connection) see the same state
# as claude writes via CLAUDE_CONFIG_DIR. The `ide` subpath does not honor the
# env var (see anthropics/claude-code#34800, #13933, #4739), so the symlink is
# required for cross-runtime parity.
mkdir -p "${config_dir}"
ln -sfn "${mounted_dir}/ide" "${config_dir}/ide"
chown -h "${target_user}:${target_user}" "${config_dir}" "${config_dir}/ide" 2>/dev/null || true

set +e

echo "${binary_name} installation complete!"
