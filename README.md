# Pi Container

Run Pi inside a Docker Compose container while mounting one or more selected
project directories.

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

Everything before `--` is a host directory to mount; the first directory is the
primary workspace and the container's working dir. Everything after `--` is
passed straight to `pi`:

```sh
bin/pi-agent ~/dev/my-project -- chat
```

### Mount multiple directories

List several directories before `--` to mount them all. Each is mounted at
`/workspace/<basename>`, so their basenames must be unique:

```sh
bin/pi-agent ~/dev/app ~/dev/shared-lib ~/dev/config -- some pi args
```

- `app` (first) is the primary workspace at `/workspace/app` and working dir.
- `shared-lib` is mounted at `/workspace/shared-lib`.
- `config` is mounted at `/workspace/config`.
- `some pi args` is forwarded to `pi`.

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

The mounted projects are available under `/workspace`, each at its own
basename:

```sh
/workspace/<name>
```

## What Pi can access

Pi can access:

```text
/workspace/<name>       each mounted project directory, by its basename
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

## Android builds and tests

The container ships JDK 17 and the Android SDK, so it can build the app and run
JVM unit tests.

It runs as `linux/amd64` (see `compose.yaml`) because AGP only ships an x86_64
AAPT2 binary. On Apple Silicon, enable Rosetta in Docker Desktop; builds are
slower under emulation.

The committed `local.properties` has a host `sdk.dir` that doesn't exist here.
Fix it before building:

```sh
echo "sdk.dir=$ANDROID_HOME" > local.properties
./gradlew :app:assembleDebug
./gradlew testDebugUnitTest
```

UI/instrumented tests (`connectedDebugAndroidTest`) don't run here: no emulator
or device, and emulators need `/dev/kvm`, unavailable on Docker Desktop. Run
those on a real device/emulator or a cloud device farm.

## Git usage inside the container

Inside the container:

```sh
git status
git pull
git push
```

Git push/pull works through the host SSH agent socket. Your private SSH keys are not copied into the container.

### Commit identity

Your commit identity (name and email) comes from your own host `~/.gitconfig`,
mounted read-only into the container by `bin/pi-agent`. Nothing is hard-coded or
committed to this repo, so each developer commits under their own identity.

If your host has no `~/.gitconfig`, an empty config is used instead (git will
prompt you to set `user.name`/`user.email` before committing). Set them on the
host with:

```sh
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

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
