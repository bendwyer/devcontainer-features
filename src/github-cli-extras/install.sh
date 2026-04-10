#!/usr/bin/env bash

set -e

GH_DATA_DIR="/var/lib/gh"
SETUP_SCRIPT_DIR="/usr/local/share/github-cli-extras"

# Ensure the mount point exists
mkdir -p "$GH_DATA_DIR"

# Copy the setup script to a well-known location for postCreateCommand
mkdir -p "$SETUP_SCRIPT_DIR"
cp setup.sh "$SETUP_SCRIPT_DIR/setup.sh"
chmod +x "$SETUP_SCRIPT_DIR/setup.sh"
