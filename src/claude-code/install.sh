#!/usr/bin/env bash

set -e

VERSION="${VERSION:-stable}"

npm install -g @anthropic-ai/claude-code@$VERSION
