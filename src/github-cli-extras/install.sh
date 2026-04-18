#!/usr/bin/env bash

set -e

target_user="${_REMOTE_USER:-root}"
if [ "${target_user}" = "root" ]; then
    target_home="/root"
else
    target_home="/home/${target_user}"
fi

mounted_dir="/var/lib/gh"
config_dir="${target_home}/.config/gh"

echo "Creating persistent state directory at ${mounted_dir}..."
# Mode 1777 (sticky bit): any user can write, and updates to the user's UID at
# runtime (devcontainer updateRemoteUserUID) do not strand writes. Individual
# files written by gh itself are created with restrictive perms by gh.
mkdir -p "${mounted_dir}"
chmod 1777 "${mounted_dir}"

echo "Linking ${config_dir} -> ${mounted_dir}..."
mkdir -p "${target_home}/.config"
chown "${target_user}:${target_user}" "${target_home}/.config" 2>/dev/null || true

ln -sfn "${mounted_dir}" "${config_dir}"
chown -h "${target_user}:${target_user}" "${config_dir}" 2>/dev/null || true

echo "github-cli-extras installation complete!"
