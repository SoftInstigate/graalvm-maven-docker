---
type: Reference
title: Dockerfile and Image Structure
description: Layer-by-layer breakdown of the Dockerfile, SDKMAN configuration, ARG-controlled versions, entrypoint behavior, and build dependencies required for native-image compilation.
tags: [dockerfile, sdkman, graalvm, build, entrypoint]
---

# Dockerfile and Image Structure

The entire image is defined in a single [`Dockerfile`](/Dockerfile) at the repository root. It builds a Debian-based container with SDKMAN-managed Java and Maven toolchains.

## Base image and layers

```
FROM debian:stable-slim
```

The image uses `debian:stable-slim` for minimal footprint. Layers are organized as two `RUN` instructions:

1. **System dependencies + SDKMAN install** — installs OS packages, sets locale, fetches SDKMAN, and writes its config.
2. **Java + Maven install** — sources SDKMAN and runs `sdk install` for both tools, then cleans up archive/temp files.

## Version control via ARGs

```dockerfile
ARG JAVA_VERSION="25-graalce"
ARG MAVEN_VERSION="3.9.11"
```

These `ARG` directives are the single source of truth for installed tool versions. To upgrade GraalVM or Maven, change these values and update the README version table to match.

The image label and git tag convention reflect the GraalVM version (e.g. `25-graalce`).

## SDKMAN configuration

SDKMAN is configured in three lines written to `$SDKMAN_DIR/etc/config`:

| Setting | Value | Purpose |
|---------|-------|---------|
| `sdkman_auto_answer` | `true` | Non-interactive installs (no prompts) |
| `sdkman_auto_selfupdate` | `false` | Prevents SDKMAN version drift at build time |
| `sdkman_insecure_ssl` | `true` | Compatibility with some corporate proxy environments |

The SDKMAN directory is `/root/.sdkman` (set via `ENV SDKMAN_DIR`).

## System build packages

These packages are installed and **must not be removed** — they are required for GraalVM native-image compilation:

- `build-essential` — C/C++ compiler toolchain
- `libz-dev`, `zlib1g-dev` — compression libraries needed by native-image
- `ca-certificates` — TLS trust store
- `fontconfig`, `locales` — locale and font support for JVM

## Entrypoint script

[`bin/entrypoint.sh`](/bin/entrypoint.sh) is a three-line shell script:

```bash
#!/bin/bash
source /root/.bashrc && mvn "$@"
```

It sources `.bashrc` to activate the SDKMAN environment (which adds `mvn` and `java` to `PATH`), then forwards all container arguments to Maven. The `Dockerfile` sets `SHELL ["/bin/bash", "-i", "-c"]` and `ENTRYPOINT ["/root/entrypoint.sh"]`.

Without sourcing `.bashrc`, `mvn` would not be found when the container starts — this is the most common cause of "command not found" errors when users override the entrypoint with a shell.

## Helper scripts

| Script | Purpose |
|--------|---------|
| [`bin/build.sh`](/bin/build.sh) | Local no-cache Docker build, tags as `:latest` |
| [`bin/push.sh`](/bin/push.sh) | Pushes `:latest` to Docker Hub (manual testing only) |

CI handles production image builds and pushes — see [CI/CD and release process](/openwiki/ci-cd.md).

## Relationship to CI/CD

The Dockerfile's `ARG` values and the README version table are the two places that must stay in sync during a release. The [CI/CD workflow](/openwiki/ci-cd.md) reads the Dockerfile as-is and publishes the resulting image under both `latest` and the git tag name.
