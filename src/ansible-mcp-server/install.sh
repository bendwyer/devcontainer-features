#!/usr/bin/env bash

set -e

VERSION="${VERSION:-latest}"

npm install -g @ansible/ansible-mcp-server@$VERSION
