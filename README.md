### `sfdx-cli`

Running `sfdx version` inside the built container will print the sfdx binary version.

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/vercellone/devcontainer-features/sfdx-cli:1": {}
    }
}
```

```bash
$ sfdx version

sfdx-cli/7.194.1 linux-x64 node-v18.15.0
```
