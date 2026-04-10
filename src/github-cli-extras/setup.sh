#!/usr/bin/env bash

set -e

GH_DATA_DIR="/var/lib/gh"
GH_CONFIG_DIR="$HOME/.config/gh"

# Take ownership of the mount point
sudo chown "$(whoami)" "$GH_DATA_DIR"

# Migrate existing config into the volume if it exists and isn't already a symlink
if [ -d "$GH_CONFIG_DIR" ] && [ ! -L "$GH_CONFIG_DIR" ]; then
    cp -a "$GH_CONFIG_DIR/." "$GH_DATA_DIR/" 2>/dev/null
    rm -rf "$GH_CONFIG_DIR"
fi

# Symlink ~/.config/gh to the persistent volume
mkdir -p "$HOME/.config"
ln -sfn "$GH_DATA_DIR" "$GH_CONFIG_DIR"
