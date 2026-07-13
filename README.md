# Pi Container

Run Pi inside a Docker Compose container while mounting only one selected project directory.

## Requirements

- Docker Desktop or OrbStack
- Git configured on the host
- SSH key loaded into your host SSH agent

Check host SSH access:

```sh
ssh -T git@github.com
```

## Build

```sh
docker compose build pi-agent
```

## Run Pi against a project

```sh
bin/pi-agent ~/dev/my-project
```

By default this also mounts your host's `~/.pi/agent/` directory (containing
`AGENT.md`, `skills/`, and `extensions/`) into the container, so your Pi
customizations can be version controlled independently of any single project.
If `~/.pi/agent` doesn't exist yet, it will be created automatically.

To use a different agent config directory, set it in `.env`:

```sh
PI_AGENT_DIR=~/dev/my-pi-agent-config
```

Inside the container:

```sh
pi
```

The mounted project is available at:

```sh
/workspace
```

## What Pi can access

Pi can access:

```text
/workspace              the mounted project
/home/piagent/.pi/agent your version-controlled Pi agent config (AGENT.md, skills, extensions)
internet                enabled by Docker Compose by default
git remotes             via forwarded SSH agent
/home/piagent           container-only Pi config/session volume
```

Pi should not be able to access:

```text
Your Mac home directory
Your real ~/.ssh private keys
Your real ~/.aws credentials
Your shell config
Other repos
Desktop/Documents/etc
```

## Git usage inside the container

Inside the container:

```sh
git status
git pull
git push
```

Git push/pull works through the host SSH agent socket. Your private SSH keys are not copied into the container.

## Pi config

Pi config should be created inside the container under:

```sh
/home/piagent
```

Likely paths include:

```sh
/home/piagent/.pi
```

Do not mount your real Mac `~/.pi` unless you intentionally want the container to share your host Pi config.

## Update Pi

Rebuild the image:

```sh
docker compose build --no-cache pi-agent
```

## Reset Pi config

This deletes the Docker volume that stores Pi config:

```sh
docker compose down -v
```
