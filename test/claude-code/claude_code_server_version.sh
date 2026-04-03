#!/usr/bin/env bash

set -e

# Import test library for `check` command
source dev-container-features-test-lib

# claude code specific tests
check "user" whoami
check "claude code location" which claude
check "claude code version" claude --version
check "claude config dir exists" ls -ld /var/lib/claude
check "claude config dir is writable" bash -c "test -w /var/lib/claude && echo writable"
check "claude.json exists" ls -la /var/lib/claude/.claude.json
check "CLAUDE_CONFIG_DIR is set" bash -c "echo \$CLAUDE_CONFIG_DIR | grep /var/lib/claude"
check "volume is mounted" bash -c "mount | grep /var/lib/claude"
check "ide symlink exists" bash -c "test -L ~/.claude/ide && readlink ~/.claude/ide | grep /var/lib/claude/ide"

# Report result
reportResults
