
# Kustomize (kustomize)

Kustomize lets you customize raw, template-free YAML files for multiple purposes, leaving the original YAML untouched and usable as is.

## Example Usage

```json
"features": {
    "ghcr.io/bendwyer/devcontainer-features/kustomize:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version to install. Anything that is not 'latest' must be in '#.#.#' format. | string | latest |

## Customizations

### VS Code Extensions

- `ms-kubernetes-tools.vscode-kubernetes-tools`


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
| 1.0.0 | Initial release |


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/bendwyer/devcontainer-features/blob/main/src/kustomize/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
