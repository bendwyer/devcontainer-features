
# 1Password CLI (op)

1Password CLI brings 1Password to your terminal. Sign in to 1Password CLI with your fingerprint, and securely access everything you need during development.

## Example Usage

```json
"features": {
    "ghcr.io/bendwyer/devcontainer-features/op:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version to install. Anything that is not 'latest' must be in '#.#.#' format. | string | latest |


## OS Support

This feature is tested against the following OS versions:

- ubuntu:noble
- debian:12
- mcr.microsoft.com/devcontainers/base:ubuntu
- mcr.microsoft.com/devcontainers/base:debian

Versions older than what are listed above are untested and therefore may not support this feature without additional packages.

## Changelog

| Version | Notes |
| --- | --- |
| 1.0.0 | Initial release |


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/bendwyer/devcontainer-features/blob/main/src/op/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
