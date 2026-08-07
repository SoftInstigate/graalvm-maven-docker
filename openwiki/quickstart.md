---
type: Guide
title: GraalVM Maven Docker — Quickstart
description: Minimal Docker image providing GraalVM and Maven via SDKMAN for building JVM apps and native images without local toolchains.
tags: [docker, graalvm, maven, sdkman, native-image]
---

# GraalVM Maven Docker — Quickstart

This repository produces a minimal Docker image with **GraalVM** (Community Edition) and **Maven** pre-installed via [SDKMAN!](https://sdkman.io). It is maintained by [SoftInstigate](https://github.com/SoftInstigate) and published to both Docker Hub and GitHub Container Registry (GHCR).

The image lets teams run Maven builds and GraalVM native-image compilations inside a clean, reproducible container without installing Java toolchains on their host machine.

## Current versions

| Component | Version |
|-----------|---------|
| GraalVM   | `25-graalce` |
| Maven     | `3.9.11` |

Versions are controlled by `ARG` directives in the [`Dockerfile`](/Dockerfile).

## Pull the image

```bash
# Docker Hub
docker pull softinstigate/graalvm-maven:25-graalce

# GHCR
docker pull ghcr.io/softinstigate/graalvm-maven:25-graalce
```

**Supported platforms:** `linux/amd64`, `linux/arm64`.

**Tag conventions:**
- `latest` — tracks the most recent release
- `25-graalce` — current main
- Historical: `24.0.2-graalce`, `22.0.2-graalce`, `21.0.2-graalce`

Browse all tags on [Docker Hub](https://hub.docker.com/r/softinstigate/graalvm-maven/tags) or [GHCR](https://github.com/SoftInstigate/graalvm-maven-docker/pkgs/container/graalvm-maven).

## Build a Maven project

The default entrypoint is `mvn`. The working directory inside the container is `/opt/app`.

```bash
# Print Maven + Java versions
docker run --rm softinstigate/graalvm-maven --version

# Build the project in the current directory
docker run -it --rm \
    -v "$PWD":/opt/app \
    -v "$HOME"/.m2:/root/.m2 \
    softinstigate/graalvm-maven \
    clean package
```

Mounting `~/.m2` reuses your local Maven cache and speeds up repeated builds.

## Native image builds

Add the [GraalVM Native Build Tools Maven plugin](https://graalvm.github.io/native-build-tools/latest/maven-plugin.html/) to your project, then:

```bash
docker run -it --rm \
    -v "$PWD":/opt/app \
    -v "$HOME"/.m2:/root/.m2 \
    softinstigate/graalvm-maven \
    -Pnative -DskipTests native:compile
```

## Troubleshooting

- **Maven not found after overriding entrypoint** — source SDKMAN before calling `mvn`:
  ```bash
  docker run -it --rm --entrypoint bash softinstigate/graalvm-maven
  source ~/.bashrc && mvn -v
  ```
- **Slow dependency downloads** — mount your local cache: `-v "$HOME"/.m2:/root/.m2`
- **Verify toolchain inside the container:**
  ```bash
  docker run -it --rm --entrypoint bash softinstigate/graalvm-maven -lc \
      'source ~/.bashrc; sdk current; java -version; mvn -version'
  ```

## Where to go next

- [Dockerfile and image structure](/openwiki/dockerfile.md) — layer breakdown, SDKMAN configuration, build dependencies, and entrypoint design.
- [CI/CD and release process](/openwiki/ci-cd.md) — GitHub Actions workflow, release steps, secrets, and OpenWiki automation.

## Backlog

No deferred areas. The repository is small enough to cover fully with the current page set.
