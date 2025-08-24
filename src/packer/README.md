
# Packer (packer)

Packer is a tool for creating identical machine images for multiple platforms from a single source configuration.

## Example Usage

```json
"features": {
    "ghcr.io/bendwyer/devcontainer-features/packer:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the version to install. Anything that is not 'latest' must be in '#.#.#' format. | string | latest |
| autocomplete | Enable shell tab-completion. | boolean | true |

## Customizations

### VS Code Extensions

- `hashicorp.hcl`


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

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/bendwyer/devcontainer-features/blob/main/src/packer/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
