# Pi Container

Run Pi in a Docker sandbox with access only to the project directories you mount.

## Requirements

- Docker Desktop or OrbStack
- Git configured on the host
- Your SSH key loaded into the host SSH agent

## Setup

Build the container:

```sh
bin/build-pi-agent
```

Add this repository's `bin/` directory to your `PATH`. For example, add the following to `~/.zshrc`, replacing the path with the location of this repository:

```sh
export PATH="$HOME/Projects/pi-container/bin:$PATH"
```

Restart your shell, then start Pi with a project mounted in sandbox mode:

```sh
pi-agent ~/dev/your-project
```

The first directory is Pi's working directory. Mount multiple directories by listing them:

```sh
pi-agent ~/dev/your-project ~/dev/another-project
```

Each directory is available at `/workspace/<directory-name>`. Directory names must be unique.

Pass arguments directly to Pi after `--`:

```sh
pi-agent ~/dev/your-project -- "Hello prompt"
```

## Configuration

By default, `~/.pi/agent` is mounted into the container for your `AGENT.md`, skills and extensions. Override it in `.env`:

```sh
PI_AGENT_DIR=~/dev/my-pi-agent-config
```

Your host Git configuration and SSH agent are available inside the container, but private SSH keys and other host files are not mounted.

## Android projects

The container includes JDK 17 and the Android SDK. Before building an Android project, point Gradle at the container SDK:

```sh
echo "sdk.dir=$ANDROID_HOME" > local.properties
./gradlew :app:assembleDebug
./gradlew testDebugUnitTest
```

Instrumented tests require a device or emulator and cannot run in the container. On Apple Silicon, enable Rosetta in Docker Desktop because Android's AAPT2 binary requires x86_64 emulation.

## Maintenance

Rebuild without the Docker cache:

```sh
bin/build-pi-agent --no-cache
```

Reset the container's Pi configuration:

```sh
docker compose down -v
```
