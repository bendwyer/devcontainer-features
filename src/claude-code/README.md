
# Claude Code (claude-code)

Claude Code is an agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows - all through natural language commands.

## Example Usage

```json
"features": {
    "ghcr.io/bendwyer/devcontainer-features/claude-code:5": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version to install. | string | stable |

## Customizations

### VS Code Extensions

- `Anthropic.claude-code`


## How `claude install` behaves

Runtime tracing (strace on `debian:12`) of the `claude install <version>` command that runs in `postCreateCommand`. Captured here because this behavior caused real friction when designing the feature.

### Summary

`claude install` is a per-user, runtime-oriented registration step. It:

1. Downloads a second copy of the binary (~222MB) into the user's home.
2. Creates per-user state, share, cache, and lock directories.
3. Writes a `.claude.json` config file honoring `CLAUDE_CONFIG_DIR` (falls back to `$HOME/.claude.json`).
4. Generates a persistent `userID` on first run.
5. Uses atomic writes (`.tmp.<pid>.<ns>` + `rename`) for all config files.
6. Is idempotent but not free — re-verifies checksums, may re-download.

### What lands where

With `CLAUDE_CONFIG_DIR=/var/lib/claude` set:

```
/var/lib/claude/                                      # (honored)
├── .claude.json                                      # mode 600, ~325 bytes
└── backups/
    └── .claude.json.backup.<epoch_ms>

$HOME/.local/bin/claude                               # (not honored) symlink
    → $HOME/.local/share/claude/versions/<version>
$HOME/.local/share/claude/versions/<version>          # (not honored) 222MB copy of the binary
$HOME/.local/state/claude/locks/                      # (not honored) IPC locks
$HOME/.cache/claude/                                  # (not honored) download staging
```

### `.claude.json` contents

```json
{
  "installMethod": "native",
  "autoUpdates": false,
  "firstStartTime": "2026-04-18T22:02:13.095Z",
  "opusProMigrationComplete": true,
  "sonnet1m45MigrationComplete": true,
  "migrationVersion": 11,
  "userID": "dea8a97e5cd0367f046b727258e51f2f8fd616e8fee0fb5608519f317c681c49",
  "autoUpdatesProtectedForNative": true
}
```

The `userID` is a persistent, machine-correlating identifier generated on first run. **This is the reason `claude install` must not run at image build time** — every workspace built from the image would share the same identifier.

### `CLAUDE_CONFIG_DIR` honors and escapes

`CLAUDE_CONFIG_DIR` replaces `~/.claude` as the user-scope config directory. Everything that previously lived under `~/.claude` (or at `~/.claude.json`) now lives under `$CLAUDE_CONFIG_DIR`. Auxiliary XDG-style paths under `$HOME/.local/` and `$HOME/.cache/` are NOT redirected.

#### What lands inside `CLAUDE_CONFIG_DIR` (persisted by a mount)

Observed in a mature live session (not a fresh install trace):

| Path (relative to `$CLAUDE_CONFIG_DIR`) | Purpose | Typical size |
| --- | --- | --- |
| `.claude.json` | User config + `userID` + per-project MCP server configs | ~25 KB |
| `.credentials.json` | Authentication tokens (OAuth / API key) | <1 KB |
| `settings.json` | User-scope settings (hooks, permissions, MCP, plugins, env) | small |
| `agents/` | User-scope subagents | small |
| `backups/` | Config backups (per install + corruption recovery) | ~200 KB |
| `cache/` | Misc cache (changelog.md, etc.) | ~250 KB |
| `file-history/` | Per-project file history for rewind/undo | ~8 MB |
| `history.jsonl` | Conversation history log | ~500 KB |
| `ide/` | IDE connection lock files (MCP server for VS Code) | small |
| `paste-cache/` | Clipboard/paste history | ~700 KB |
| `plans/` | Plan mode documents | small |
| `plugins/` | Installed plugin content AND registry JSON | ~5 MB |
| `projects/<project>/` | Per-project sessions, auto-memory, and related state | **~100 MB** |
| `session-env/` | Saved environment variable snapshots per session | small |
| `sessions/` | Conversation session metadata | small |
| `shell-snapshots/` | Shell command output snapshots | small |
| `stats-cache.json` | Usage/stats cache | small |
| `tasks/` | Task state | small |
| `telemetry/` | Telemetry state | small |

**All of these are persisted when `/var/lib/claude` is backed by a volume mount.** The `projects/` subtree is the largest piece — it holds session histories, auto-memory, and per-working-tree state.

#### What does NOT honor `CLAUDE_CONFIG_DIR` (lives under XDG paths in `$HOME`)

The binary reads XDG base-directory variables (`XDG_STATE_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`) with standard fallbacks. These are independent of `CLAUDE_CONFIG_DIR`.

| Path | Purpose | Persistence worth? |
| --- | --- | --- |
| `$HOME/.local/bin/claude` | User-facing symlink → versioned binary | No (rebuildable by `claude install`) |
| `$HOME/.local/share/claude/versions/<v>` | Per-user binary copy (~222MB) | No (rebuildable; large) |
| `$HOME/.local/state/claude/locks/` | IPC locks | No (ephemeral by nature) |
| `$HOME/.cache/claude/` | Download staging | No (cache) |

None of the paths observed in traces hold authentication or user state that needs to survive rebuilds.

#### Additional paths outside both `$CLAUDE_CONFIG_DIR` and `$HOME/.local`

Claude also writes one thing outside the patterns above:

- `$HOME/.local/share/applications/claude-code-url-handler.desktop` — XDG desktop entry so the OS can handle `vscode://anthropic.claude-code/open` URLs. Cosmetic; not persisted; recreated on install.

#### Paths inside `~/.claude` that DO NOT honor `CLAUDE_CONFIG_DIR`

Despite `CLAUDE_CONFIG_DIR` redirecting most of `~/.claude/`, some consumers read specific subpaths literally:

- `~/.claude/ide/` — VS Code extension's IDE MCP server connection writes lock files to this path literally; it does not follow `CLAUDE_CONFIG_DIR`. Tracked upstream in [anthropics/claude-code#34800](https://github.com/anthropics/claude-code/issues/34800), [#13933](https://github.com/anthropics/claude-code/issues/13933), and [#4739](https://github.com/anthropics/claude-code/issues/4739) (all closed without a code fix).

This feature's install.sh works around the bug by creating a symlink `~/.claude/ide` → `/var/lib/claude/ide` at build time so both code paths see the same state. Without it, the VS Code extension would not see IDE connection locks claude writes via `CLAUDE_CONFIG_DIR`.

#### Project-scope paths (NOT user-scope, NOT redirected)

These live inside the project directory and are not managed by this feature at all — they're committed to the project repo or placed by the user:

| Path | Scope |
| --- | --- |
| `.claude/settings.json` | Project-scope settings (shared via git) |
| `.claude/settings.local.json` | Local project-scope settings (gitignored) |
| `.claude/agents/` | Project-scope subagents |
| `.claude/CLAUDE.md` or `CLAUDE.md` | Project memory |
| `.mcp.json` | Project MCP servers |

#### Managed (system-scope) paths

Claude Code also reads system-managed settings from `/etc/claude-code/`:

| Path | Purpose |
| --- | --- |
| `/etc/claude-code/managed-settings.json` | Org-enforced settings (not overridable) |
| `/etc/claude-code/managed-settings.d/` | Directory of additional managed settings |
| `/etc/claude-code/managed-mcp.json` | Managed MCP configuration |

Not relevant to most devcontainer users; noted for completeness.

### Write semantics

All config writes use atomic-rename:

```
openat(… "/var/lib/claude/.claude.json.tmp.2939.1776549733104" …)
rename("/var/lib/claude/.claude.json.tmp.2939.1776549733104",
       "/var/lib/claude/.claude.json") = 0
```

Symlinking individual files like `$HOME/.claude.json` does not survive — the atomic rename replaces the symlink with a regular file on first write.

During a single install, `.claude.json` is rewritten multiple times as install state advances.

### Symlink created by `claude install`

```
$HOME/.local/bin/claude → $HOME/.local/share/claude/versions/<version>
```

The user-facing `claude` command is the symlink. Real binary at the versioned path. Makes version switching cheap.

### Binary duplication

Each `claude install` places ~222MB at `$HOME/.local/share/claude/versions/<version>`. The feature's own install script places a byte-identical copy at `/usr/local/bin/claude` during image build. Both coexist: the system binary is used until `~/.local/bin` is on PATH.

Running `claude install` at image build time would bake the 222MB duplicate into the image layer permanently — another reason to keep it in `postCreateCommand`.

### Network behavior

`claude install` is not offline-safe. During install it connects to:

- `storage.googleapis.com` (GCS ranges, `142.251.*`, `172.217.*`) — downloads the versioned binary
- `160.79.104.10:443` — Anthropic's server (telemetry/registration)

In air-gapped builds this will fail.

### Runtime requirements

`claude install` must run:

1. **As the target user** (not root, unless target user is root) — it writes into `$HOME`.
2. **After `$HOME` exists.**
3. **With `CLAUDE_CONFIG_DIR` set** to put config in a mountable location.
4. **With network access.**

### What breaks if `claude install` is skipped

Envbuilder ignores feature-level `postCreateCommand`, so in Coder workspaces `claude install` does not run. In that case:

- `/usr/local/bin/claude` still exists (from this feature's install.sh).
- The user can run `claude` and it works.
- `.claude.json` is created in `/var/lib/claude` on first `claude` invocation (still via `CLAUDE_CONFIG_DIR`).
- No `~/.local/bin/claude` symlink, no 222MB duplicate, no version-switching infrastructure.

The binary works without `claude install`. The command is polish (user-facing symlink, version switching).

### Key paths reference

Compiled from a real live session, not just the install trace.

| Path | Created by | Purpose |
| --- | --- | --- |
| `/usr/local/bin/claude` | feature install.sh | System-wide binary |
| `/usr/local/share/claude-version` | feature install.sh | Version for postCreate |
| `/var/lib/claude/.claude.json` | `claude install` + user activity | Config + `userID` + per-project MCP |
| `/var/lib/claude/.credentials.json` | `claude login` | Auth tokens |
| `/var/lib/claude/settings.json` | User activity / `/config` | User-scope settings |
| `/var/lib/claude/agents/` | User activity | User-scope subagents |
| `/var/lib/claude/backups/` | `claude install` + corruption recovery | Config backups |
| `/var/lib/claude/cache/` | Runtime | Misc cache |
| `/var/lib/claude/file-history/` | Runtime | Per-project file history (rewind) |
| `/var/lib/claude/history.jsonl` | Runtime | Conversation history log |
| `/var/lib/claude/ide/*.lock` | Runtime | IDE MCP connection locks |
| `/var/lib/claude/paste-cache/` | Runtime | Clipboard/paste history |
| `/var/lib/claude/plans/` | User activity | Plan mode documents |
| `/var/lib/claude/plugins/` | User activity | Plugin content + registry |
| `/var/lib/claude/projects/<project>/` | Runtime | Per-project sessions, auto-memory |
| `/var/lib/claude/session-env/` | Runtime | Environment snapshots per session |
| `/var/lib/claude/sessions/` | Runtime | Session metadata |
| `/var/lib/claude/shell-snapshots/` | Runtime | Shell output snapshots |
| `/var/lib/claude/stats-cache.json` | Runtime | Usage stats cache |
| `/var/lib/claude/tasks/` | Runtime | Task state |
| `/var/lib/claude/telemetry/` | Runtime | Telemetry |
| `$HOME/.local/bin/claude` | `claude install` | User-facing symlink |
| `$HOME/.local/share/claude/versions/<v>` | `claude install` | Per-user binary copy (~222 MB each; multiple can accumulate) |
| `$HOME/.local/state/claude/locks/` | Runtime | IPC locks |
| `$HOME/.cache/claude/staging` | `claude install` | Download staging |
| `$HOME/.local/share/applications/claude-code-url-handler.desktop` | `claude install` | XDG URL handler (cosmetic) |
| `$HOME/.claude/` | Runtime | Empty dir; harmless |
| `/etc/claude-code/managed-settings.json` | Operator | System-wide managed settings |

### Trace captured on

- Image: `debian:12` (Debian GNU/Linux 12 bookworm), linux-x64
- Claude Code version: 2.1.98 (stable channel)
- Date: 2026-04-18

## OS Support

This feature is tested against the following images:

- ubuntu:24.04
- debian:12
- mcr.microsoft.com/devcontainers/base:ubuntu24.04
- mcr.microsoft.com/devcontainers/base:debian12

This feature is tested against the following architectures:

- amd64
- arm64

## Changelog

| Version | Notes |
| --- | --- |
| 5.0.0 | Refactor install.sh |
| 4.0.1 | Fix IDE detection bug |
| 4.0.0 | Add data persistence |
| 3.0.0 | Switch to native installation |
| 2.0.0 | Switch to npm installation |
| 1.0.1 | Improve curl installation flow |
| 1.0.0 | Initial release |


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/bendwyer/devcontainer-features/blob/main/src/claude-code/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
