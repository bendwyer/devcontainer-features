#!/usr/bin/env bash

set -e

PRODUCT_NAME="packer"
PRODUCT_VERSION=${VERSION:-"latest"}
PRODUCT_AUTOCOMPLETE=${AUTOCOMPLETE:-true}

if [ $(uname -m) = "aarch64" ] || [ $(uname -m) = "arm64" ]; then
  OS_ARCH="arm64"
else
  OS_ARCH="amd64"
fi

export DEBIAN_FRONTEND=noninteractive

echo "Checking if curl is installed..."
if type curl > /dev/null 2>&1; then
    echo "curl already installed. Skipping..."
else
  echo "Installing curl..."
  apt-get -yq update
  apt-get -yq install curl
  echo "curl installation complete!"
fi

echo "Checking if unzip is installed..."
if type unzip > /dev/null 2>&1; then
    echo "unzip already installed. Skipping..."
else
  echo "Installing unzip..."
  apt-get -yq update
  apt-get -yq install unzip
  echo "unzip installation complete!"
fi

echo "Checking if ${PRODUCT_NAME} is installed..."
if [ "${PRODUCT_VERSION}" = "none" ] || type ${PRODUCT_NAME} > /dev/null 2>&1; then
    echo "${PRODUCT_NAME} already installed. Skipping..."
else
  echo "Installing ${PRODUCT_NAME}..."
  if [ "${PRODUCT_VERSION}" = "latest" ] ; then
    echo "Checking if jq is installed..."
    if type jq > /dev/null 2>&1; then
        echo "jq already installed. Skipping..."
    else
      echo "Installing jq..."
      apt-get -yq update
      apt-get -yq install jq
      echo "jq installation complete!"
    fi
    PRODUCT_VERSION=$(curl -sL https://api.github.com/repos/hashicorp/${PRODUCT_NAME}/releases/latest | jq -r '.tag_name | split("v")[1]')
    curl -sLO https://releases.hashicorp.com/${PRODUCT_NAME}/${PRODUCT_VERSION}/${PRODUCT_NAME}_${PRODUCT_VERSION}_linux_${OS_ARCH}.zip | unzip -j ${PRODUCT_NAME}_${PRODUCT_VERSION}_linux_${OS_ARCH}.zip ${PRODUCT_NAME} -d /usr/local/bin/
  else
    curl -sLO https://releases.hashicorp.com/${PRODUCT_NAME}/${PRODUCT_VERSION}/${PRODUCT_NAME}_${PRODUCT_VERSION}_linux_${OS_ARCH}.zip | unzip -j ${PRODUCT_NAME}_${PRODUCT_VERSION}_linux_${OS_ARCH}.zip ${PRODUCT_NAME} -d /usr/local/bin/
  fi
  rm -f ${PRODUCT_NAME}_${PRODUCT_VERSION}_linux_${OS_ARCH}.zip
fi

if [ "${PRODUCT_AUTOCOMPLETE}" = "true" ]; then
  echo "Installing ${PRODUCT_NAME} shell tab-completion..."
  check_packages sudo
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
      ${PRODUCT_NAME} -autocomplete-install
      . \$USER_LOCATION/.bashrc
      echo "${PRODUCT_NAME} bash tab-completion installed successfully!"
    fi
EOF
fi

set +e

echo "${PRODUCT_NAME} installation complete!"
