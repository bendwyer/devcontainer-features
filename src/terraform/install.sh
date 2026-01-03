#!/usr/bin/env bash

set -e

VERSION="${VERSION:-latest}"
AUTOCOMPLETE="${AUTOCOMPLETE:-true}"
binary_name="terraform"

arch=$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/')

echo "Checking if ${binary_name} is installed..."
if [ "${VERSION}" = "none" ] || type ${binary_name} > /dev/null 2>&1; then
    echo "${binary_name} already installed. Skipping..."
else
  echo "Installing ${binary_name}..."
  if [ "${VERSION}" = "latest" ] ; then
    binary_version=$(curl -sSL https://api.github.com/repos/hashicorp/${binary_name}/releases/latest | jq -r '.tag_name | split("v")[1]')
  else
    binary_version="${VERSION}"
  fi
  curl -sSLO https://releases.hashicorp.com/${binary_name}/${binary_version}/${binary_name}_${binary_version}_linux_${arch}.zip && unzip -jq ${binary_name}_${binary_version}_linux_${arch}.zip ${binary_name} -d /usr/local/bin/
  rm -f ${binary_name}_${binary_version}_linux_${arch}.zip
fi

if [ "${AUTOCOMPLETE}" = "true" ]; then
  echo "Installing ${binary_name} bash autocompletion..."
  sudo -iu "$_REMOTE_USER" <<EOF
    # https://github.com/devcontainers-contrib/features/blob/9a1d24b27b2d1ea8916ebe49c9ce674375dced27/src/pulumi/install.sh
    set -eo pipefail
    if [ "$_REMOTE_USER" == "root" ]; then
      USER_LOCATION="/root"
      echo "$_REMOTE_USER HOME is \$USER_LOCATION"
    else
      USER_LOCATION="/home/$_REMOTE_USER"
      echo "$_REMOTE_USER HOME is \$USER_LOCATION"
    fi
    cd \$USER_LOCATION
    echo "Changed to \$USER_LOCATION"
    if [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
      echo "$SHELL detected"
      if [ ! -f "\$USER_LOCATION/.bashrc" ] || [ ! -s "\$USER_LOCATION/.bashrc" ]; then
        echo ".bashrc missing"
        sudo cp  /etc/skel/.bashrc "\$USER_LOCATION/.bashrc"
        echo ".bashrc copied"
      fi
      if  [ ! -f "\$USER_LOCATION/.profile" ] || [ ! -s "\$USER_LOCATION/.profile" ]; then
        echo ".profile missing"
        sudo cp  /etc/skel/.profile "\$USER_LOCATION/.profile"
        echo ".profile copied"
      fi
      $binary_name -install-autocomplete
      . \$USER_LOCATION/.bashrc
      echo "$binary_name bash autocompletion installed successfully!"
    fi
EOF
fi

set +e

echo "${binary_name} installation complete!"
