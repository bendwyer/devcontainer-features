
# kubelogin (kubelogin)

kubectl plugin for Kubernetes OpenID Connect authentication (kubectl oidc-login)

## Example Usage

```json
"features": {
    "ghcr.io/bendwyer/devcontainer-features/kubelogin:1": {}
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
- mcr.microsoft.com/devcontainers/base:ubuntu24.04
- mcr.microsoft.com/devcontainers/base:debian12

Versions older than what are listed above are untested and therefore may not support this feature without additional packages.

## Changelog

| Version | Notes |
| --- | --- |
| 1.0.0 | Initial release |


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/bendwyer/devcontainer-features/blob/main/src/kubelogin/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
