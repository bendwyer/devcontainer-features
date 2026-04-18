
# omnictl (omnictl)

omnictl is the command-line tool for Omni. It lets you authenticate, manage, and interact with Talos-based Kubernetes clusters through a centralized API.

## Example Usage

```json
"features": {
    "ghcr.io/bendwyer/devcontainer-features/omnictl:2": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version to install. Anything that is not 'latest' must be in '#.#.#' format. | string | latest |


## OS Support

This feature is tested against the following OS versions:

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
| 2.0.0 | Refactor bash completion and required packages |
| 1.1.0 | Add bash completion |
| 1.0.0 | Initial release |


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/bendwyer/devcontainer-features/blob/main/src/omnictl/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
