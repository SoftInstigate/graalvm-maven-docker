# Copilot Instructions for graalvm-maven-docker

## Project Overview

This is a Docker image build project providing GraalVM + Maven via SDKMAN. The image is published to both Docker Hub (`softinstigate/graalvm-maven`) and GitHub Container Registry (`ghcr.io/softinstigate/graalvm-maven`).

**Key Purpose**: Enable developers to run Maven builds with GraalVM (for native image compilation) without local installation, using volume mounts for project code and Maven cache.

## Architecture

- **Base**: `debian:stable-slim` for minimal footprint
- **Package Manager**: SDKMAN installed via curl, manages both Java and Maven versions
- **Entrypoint**: Custom shell wrapper (`bin/entrypoint.sh`) that sources `.bashrc` before executing `mvn`
- **Multi-arch Support**: Built for `linux/amd64` and `linux/arm64` via GitHub Actions

## Version Management

Versions are controlled via Dockerfile ARGs:
- `JAVA_VERSION`: Currently `"25-graalce"` (GraalVM Community Edition)
- `MAVEN_VERSION`: Currently `"3.9.11"`

**To update versions**: Modify the `ARG` values in `Dockerfile`, then tag the commit to trigger automated build/push.

## Build & Release Workflow

### Local Development
```bash
# Build locally (no-cache to ensure fresh installs)
./bin/build.sh

# Test the image
docker run -it --rm softinstigate/graalvm-maven --version

# Push manually (for testing only - production uses CI)
./bin/push.sh
```

### Production Release
1. Update version ARGs in `Dockerfile` if needed
2. Update version documentation in `README.md`
3. Commit changes: `git commit -am "Update to GraalVM X.Y"`
4. Tag the commit: `git tag vX.Y.Z`
5. Push with tags: `git push && git push --tags`
6. GitHub Actions (`.github/workflows/deploy-image.yml`) automatically builds multi-arch images and pushes to both registries

**Important**: Only tagged commits trigger image deployment. Tags should follow semantic versioning (`v1.2.3`).

## Critical Implementation Details

### SDKMAN Configuration
The Dockerfile configures SDKMAN with specific flags:
- `sdkman_auto_answer=true`: Non-interactive installs
- `sdkman_auto_selfupdate=false`: Prevents version drift
- `sdkman_insecure_ssl=true`: Required for some corporate environments

### Entrypoint Design
`bin/entrypoint.sh` sources `.bashrc` to activate SDKMAN environment before executing Maven. Without this, `mvn` wouldn't be in PATH. The entrypoint passes all arguments directly to Maven via `"$@"`.

### Build Dependencies
System packages (`build-essential`, `libz-dev`, `zlib1g-dev`) are required for GraalVM native-image compilation. Don't remove these even if they seem unused.

## Common Tasks

### Testing Image Changes Locally
```bash
./bin/build.sh
docker run -it --rm -v "$PWD":/opt/app softinstigate/graalvm-maven --version
docker run -it --rm -v "$PWD":/opt/app softinstigate/graalvm-maven native:compile --help
```

### Debugging SDKMAN Issues
```bash
docker run -it --rm --entrypoint bash softinstigate/graalvm-maven
# Then inside container:
source ~/.bashrc
sdk list java
sdk current
```

## Project Conventions

- **No local build artifacts**: This project builds Docker images only, not Java projects
- **Shell scripts are executable**: All `bin/*.sh` files should have execute permissions
- **Image tagging**: `latest` tag is always applied; version tags come from git tags via CI
- **README is canonical**: Version numbers in README must match Dockerfile ARGs

## External Integrations

- **Docker Hub**: Credentials via `DOCKER_USER` and `DOCKER_TOKEN` secrets
- **GitHub Container Registry**: Authenticated via `GITHUB_TOKEN` (automatic)
- **Multi-arch builds**: Uses QEMU and Buildx in GitHub Actions
