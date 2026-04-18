
# tflint (tflint)

tflint is a pluggable Terraform linter.

## Example Usage

```json
"features": {
    "ghcr.io/bendwyer/devcontainer-features/tflint:2": {}
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
| 2.0.0 | Refactor install.sh |
| 1.0.1 | Migrate to devcontainers-extra repo |
| 1.0.0 | Initial release |


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/bendwyer/devcontainer-features/blob/main/src/tflint/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
