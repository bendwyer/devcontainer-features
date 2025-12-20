devcontainer-features
=====================

> [!NOTE]
> This repo provides custom [dev container Features](https://containers.dev/implementors/features/), hosted for free on GitHub Container Registry.

Repo and Feature Structure
--------------------------

Similar to the [`devcontainers/features`](https://github.com/devcontainers/features) repo, this repository has a `src` folder.  Each Feature has its own sub-folder, containing at least a `devcontainer-feature.json` and an entrypoint script `install.sh`.

An [implementing tool](https://containers.dev/supporting#tools) will composite [the documented dev container properties](https://containers.dev/implementors/features/#devcontainer-feature-json-properties) from the feature's `devcontainer-feature.json` file, and execute in the `install.sh` entrypoint script in the container during build time.  Implementing tools are also free to process attributes under the `customizations` property as desired.

### Options

All available options for a Feature should be declared in the `devcontainer-feature.json`.  The syntax for the `options` property can be found in the [devcontainer Feature json properties reference](https://containers.dev/implementors/features/#devcontainer-feature-json-properties).

Options are exported as Feature-scoped environment variables.  The option name is captialized and sanitized according to [option resolution](https://containers.dev/implementors/features/#option-resolution).

Distributing Features
---------------------

### Versioning

Features are individually versioned by the `version` attribute in a Feature's `devcontainer-feature.json`.  Features are versioned according to the semver specification. More details can be found in [the dev container Feature specification](https://containers.dev/implementors/features/#versioning).

### Testing

`BUILDKIT_PROGRESS=plain` is useful for troubleshooting issues or validating output.

```shell
env BUILDKIT_PROGRESS=plain devcontainer features test -f claude-code -i mcr.microsoft.com/devcontainers/base:debian12
```

See `devcontainer features test --help` for more information.

### Publishing

> [!NOTE]
> The Distribution spec can be [found here](https://containers.dev/implementors/features-distribution/).
>
> While any registry [implementing the OCI Distribution spec](https://github.com/opencontainers/distribution-spec) can be used, this template will leverage GHCR (GitHub Container Registry) as the backing registry.

Features are meant to be easily sharable units of dev container configuration and installation code.

This repo contains a **GitHub Action** [workflow](.github/workflows/features-release.yml) that will publish each Feature to GHCR.

*Allow GitHub Actions to create and approve pull requests* should be enabled in the repository's `Settings > Actions > General > Workflow permissions` for auto generation of `src/<feature>/README.md` per Feature (which merges any existing `src/<feature>/NOTES.md`).

By default, each Feature will be prefixed with the `<owner/<repo>` namespace.

The provided GitHub Action will also publish a "metadata" package with just the namespace, eg: `ghcr.io/devcontainers/<repository-name>`.  This contains information useful for tools aiding in Feature discovery.

'`devcontainers/<repository-name>`' is known as the feature collection namespace.

### Marking Feature Public

Note that by default, GHCR packages are marked as `private`.  To stay within the free tier, Features need to be marked as `public`.

This can be done by navigating to the Feature's "package settings" page in GHCR, and setting the visibility to 'public`.  The URL may look something like:

```
https://github.com/users/<owner>/packages/container/<repo>%2F<featureName>/settings
```

<img width="669" alt="image" src="https://user-images.githubusercontent.com/23246594/185244705-232cf86a-bd05-43cb-9c25-07b45b3f4b04.png">
