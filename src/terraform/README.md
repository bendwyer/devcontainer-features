
# Terraform (terraform)

Installs the Terraform CLI.

## Example Usage

```json
"features": {
    "ghcr.io/bendwyer/devcontainer-features/terraform:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Terraform version | string | latest |
| installTerraformDocs | Install terraform-docs | boolean | false |
| httpProxy | Connect to a keyserver using a proxy by configuring this option | string | - |

## Customizations

### VS Code Extensions

- `HashiCorp.terraform`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/bendwyer/devcontainer-features/blob/main/src/terraform/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
