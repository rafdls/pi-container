# pi-container

`picon` runs the [Pi coding agent](https://www.npmjs.com/package/@earendil-works/pi-coding-agent) inside a container that can only see the directories you hand it. Everything else on your machine, including your SSH keys, browser profiles and the rest of your home directory, stays out of reach.

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [OrbStack](https://orbstack.dev)
- Git configured on the host, so commits made in the container carry your name and email
- An SSH key loaded into the host SSH agent, if you want to push and pull over SSH

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/rafdls/pi-container/main/install.sh | sh
```

This installs the `picon` command to `~/.local/bin`. The container image downloads on your first run.

<details>
<summary>Build the image yourself instead</summary>

Use this if you want to change the Dockerfile or pin a different Pi version.

```sh
git clone https://github.com/rafdls/pi-container.git
cd pi-container
bin/build
export PATH="$PWD/bin:$PATH"
```

`bin/build` tags the image with the same name `picon` looks for, so `picon` uses your local build and never downloads anything. Everything below works the same either way.

</details>

## Use

Start Pi with one project mounted:

```sh
picon ~/dev/your-project
```

The first directory is Pi's working directory. Mount more by listing them:

```sh
picon ~/dev/your-project ~/dev/shared-lib
```

Each directory appears at `/workspace/<directory-name>`, so the names must be unique. Pass arguments to Pi after `--`:

```sh
picon ~/dev/your-project -- "Hello prompt"
```

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `PI_AGENT_DIR` | `~/.pi/agent` | Your `AGENT.md`, skills and extensions, mounted into the container |
| `PICON_IMAGE` | `ghcr.io/rafdls/pi-container:latest` | The image to run |

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

If you built from source, rebuild without the layer cache:

```sh
bin/build --no-cache
```
