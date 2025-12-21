#!/usr/bin/env bash

set -e

VERSION="${VERSION:-stable}"

# Configuration
GCS_BUCKET="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
INSTALL_DIR="/usr/local/bin"
DOWNLOAD_DIR="/tmp/claude-install-$$"

# Check for required dependencies
DOWNLOADER=""
if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget"
else
    echo "Error: Either curl or wget is required but neither is installed" >&2
    exit 1
fi

# Check if jq is available (optional)
HAS_JQ=false
if command -v jq >/dev/null 2>&1; then
    HAS_JQ=true
fi

# Download function that works with both curl and wget
download_file() {
    local url="$1"
    local output="$2"

    if [ "$DOWNLOADER" = "curl" ]; then
        if [ -n "$output" ]; then
            curl -fsSL -o "$output" "$url"
        else
            curl -fsSL "$url"
        fi
    elif [ "$DOWNLOADER" = "wget" ]; then
        if [ -n "$output" ]; then
            wget -q -O "$output" "$url"
        else
            wget -q -O - "$url"
        fi
    else
        return 1
    fi
}

# Simple JSON parser for extracting checksum when jq is not available
get_checksum_from_manifest() {
    local json="$1"
    local platform="$2"

    # Normalize JSON to single line and extract checksum
    json=$(echo "$json" | tr -d '\n\r\t' | sed 's/ \+/ /g')

    # Extract checksum for platform using bash regex
    if [[ $json =~ \"$platform\"[^}]*\"checksum\"[[:space:]]*:[[:space:]]*\"([a-f0-9]{64})\" ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi

    return 1
}

# Detect platform
case "$(uname -s)" in
    Darwin) os="darwin" ;;
    Linux) os="linux" ;;
    *) echo "Error: Windows is not supported" >&2; exit 1 ;;
esac

case "$(uname -m)" in
    x86_64|amd64) arch="x64" ;;
    arm64|aarch64) arch="arm64" ;;
    *) echo "Error: Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

# Check for musl on Linux and adjust platform accordingly
if [ "$os" = "linux" ]; then
    if [ -f /lib/libc.musl-x86_64.so.1 ] || [ -f /lib/libc.musl-aarch64.so.1 ] || ldd /bin/ls 2>&1 | grep -q musl; then
        platform="linux-${arch}-musl"
    else
        platform="linux-${arch}"
    fi
else
    platform="${os}-${arch}"
fi

echo "Installing Claude Code for $platform..."

mkdir -p "$DOWNLOAD_DIR"

# Resolve the version to download
if [ "$VERSION" = "stable" ] || [ "$VERSION" = "latest" ]; then
    resolved_version=$(download_file "$GCS_BUCKET/$VERSION")
    echo "Downloading $VERSION version: $resolved_version..."
else
    resolved_version="$VERSION"
    echo "Downloading version $resolved_version..."
fi

# Download manifest and extract checksum
manifest_json=$(download_file "$GCS_BUCKET/$resolved_version/manifest.json")

# Use jq if available, otherwise fall back to pure bash parsing
if [ "$HAS_JQ" = true ]; then
    checksum=$(echo "$manifest_json" | jq -r ".platforms[\"$platform\"].checksum // empty")
else
    checksum=$(get_checksum_from_manifest "$manifest_json" "$platform")
fi

# Validate checksum format (SHA256 = 64 hex characters)
if [ -z "$checksum" ] || [[ ! "$checksum" =~ ^[a-f0-9]{64}$ ]]; then
    echo "Error: Platform $platform not found in manifest" >&2
    rm -rf "$DOWNLOAD_DIR"
    exit 1
fi

# Download binary
binary_path="$DOWNLOAD_DIR/claude"
if ! download_file "$GCS_BUCKET/$resolved_version/$platform/claude" "$binary_path"; then
    echo "Error: Download failed" >&2
    rm -rf "$DOWNLOAD_DIR"
    exit 1
fi

# Verify checksum
if [ "$os" = "darwin" ]; then
    actual=$(shasum -a 256 "$binary_path" | cut -d' ' -f1)
else
    actual=$(sha256sum "$binary_path" | cut -d' ' -f1)
fi

if [ "$actual" != "$checksum" ]; then
    echo "Error: Checksum verification failed" >&2
    rm -rf "$DOWNLOAD_DIR"
    exit 1
fi

# Install binary to system location for all users
chmod +x "$binary_path"
mv "$binary_path" "$INSTALL_DIR/claude"
echo "Binary installed to $INSTALL_DIR/claude"

# Save installed version for postCreateCommand
echo "$resolved_version" > /usr/local/share/claude-version

# Clean up
rm -rf "$DOWNLOAD_DIR"

echo ""
echo "✅ Claude Code installation complete!"
echo "Note: Run 'claude install' to register the installation for your user."
echo ""
