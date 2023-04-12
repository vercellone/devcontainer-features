
# Salesforce CLI (sfdx-cli)

Installs the Salesforce CLI.

## Example Usage

```json
"features": {
    "ghcr.io/vercellone/devcontainer-features/sfdx-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| url | URL of TAR File. Refer to https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm#sfdx_setup_install_cli_linux for options. | string | https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.gz |

## OS Support

This Feature should work on recent versions of Debian/Ubuntu-based distributions.

`bash` is required to execute the `install.sh` script.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/vercellone/devcontainer-features/blob/main/src/sfdx-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
