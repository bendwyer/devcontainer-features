#!/usr/bin/env bash

set -e

VERSION="${VERSION:-latest}"
package_name="zensical"

if [ "${VERSION}" = "latest" ]; then
  pipx install "${package_name}" --include-deps
else
  pipx install "${package_name}"=="${VERSION}" --include-deps
fi

echo "${package_name} installation complete!"
