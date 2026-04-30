
# Salesforce CLI (sf-cli)

Installs the Salesforce CLI (`sf`), the next-generation Salesforce CLI (v2+).

## Example Usage

```json
"features": {
    "ghcr.io/vercellone/devcontainer-features/sf-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version/channel to install. 'latest' installs the latest stable release from the Salesforce stable channel. | string | latest |

## OS Support

This Feature should work on recent versions of Debian/Ubuntu-based distributions.

Both `amd64` (x86_64) and `arm64` (aarch64) architectures are supported.

`bash` is required to execute the `install.sh` script.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/vercellone/devcontainer-features/blob/main/src/sf-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
