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

# Prepare the CLAUDE_CONFIG_DIR mount point, owned by the target user.
# Target user defaults to _REMOTE_USER (set by the devcontainer runtime), falling back to root.
# chown is best-effort: if the user does not yet exist (e.g. common-utils hasn't run), we skip silently.
target_user="${_REMOTE_USER:-root}"
mounted_dir="/var/lib/claude"
mkdir -p "${mounted_dir}"
chown "${target_user}:${target_user}" "${mounted_dir}" 2>/dev/null || true

set +e

echo "${binary_name} installation complete!"
