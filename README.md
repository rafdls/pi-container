# pi-container

`picon` runs the [Pi coding agent](https://www.npmjs.com/package/@earendil-works/pi-coding-agent) inside a container that can only see the directories you mount on it. Everything else on your machine, including your SSH keys, browser profiles and the rest of your home directory, is inaccessible by `Pi`.

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [OrbStack](https://orbstack.dev)
- Git configured on the host for git configuration
- An SSH key loaded into the host SSH agent, if you want to push and pull over SSH

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/rafdls/pi-container/main/install.sh | sh
```

This installs the `picon` command to `~/.local/bin`. The container image downloads on your first run.

To change the Dockerfile or pin a different Pi version, see [Build from source](#build-from-source) instead.

## Use

Start Pi with one project mounted:

```sh
picon ~/Projects/your-project
```

The first directory is Pi's working directory. Mount more by listing them:

```sh
picon ~/Projects/your-project ~/Projects/shared-lib
```

Each directory appears at `/workspace/<directory-name>`, so the names must be unique. Pass arguments to Pi after `--`:

```sh
picon ~/dev/your-project -- "Hello prompt"
```

## Configuration

`picon` reads two environment variables.

| Variable | Default | Purpose |
| --- | --- | --- |
| `PI_AGENT_DIR` | `~/.pi/agent` | Your `AGENT.md`, skills and extensions, mounted into the container |
| `PICON_IMAGE` | `ghcr.io/rafdls/pi-container:latest` | The image to run |

Set one for a single run:

```sh
PI_AGENT_DIR=~/dev/my-pi-config picon ~/dev/your-project
```

Or add it to `~/.zshrc` to make it the default:

```sh
echo 'export PI_AGENT_DIR="$HOME/dev/my-pi-config"' >> ~/.zshrc
```

Shared with the container: the directories you list, your agent config, your Git name and email (read-only), and your SSH agent.

Not shared: your home directory, your private SSH keys, and every other directory on the host.

## Maintenance

Update to the latest image:

```sh
picon --pull
```

Reset Pi's own state, such as its sessions and credentials:

```sh
docker volume rm picon-home
```

## Build from source

Build the image yourself when you want to change the Dockerfile or run a different Pi version.

```sh
git clone https://github.com/rafdls/pi-container.git
cd pi-container
bin/build-picon
```

`bin/build-picon` tags the image with the same name `picon` looks for, so a local build is used and nothing is downloaded. Install the launcher from your clone:

```sh
cp bin/picon ~/.local/bin/picon
```

Use `picon` exactly as described in [Use](#use). To build a different Pi version, pass it to Docker:

```sh
docker build --build-arg PI_VERSION=0.84.2 -t ghcr.io/rafdls/pi-container:latest .
```

Rebuild without the layer cache:

```sh
bin/build-picon --no-cache
```
