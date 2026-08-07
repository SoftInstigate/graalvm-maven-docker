# graalvm-maven-docker

[![Docker image](https://github.com/SoftInstigate/graalvm-maven-docker/actions/workflows/deploy-image.yml/badge.svg)](https://github.com/SoftInstigate/graalvm-maven-docker/actions/workflows/deploy-image.yml)

A minimal Docker image that packages [GraalVM](https://graalvm.org) and [Apache Maven](https://maven.apache.org) for building JVM applications and compiling GraalVM native images. No local toolchain setup required.

## Purpose

Building Java applications—especially GraalVM native images—requires a specific combination of JDK, build tools, and native libraries. Developers waste time installing and maintaining these toolchains across machines, CI runners, and team environments. This image solves that problem by providing a ready-to-use, versioned build environment.

### Why use this image?

- **Zero local setup** — Pull the image and start building. No JDK, Maven, or GraalVM installation needed.
- **Reproducible builds** — Pin a tag (e.g. `25-graalce`) and every developer and CI job gets the exact same toolchain.
- **Native image support** — Includes all dependencies (`build-essential`, `libz-dev`, `zlib1g-dev`) required by GraalVM's `native-image` compiler out of the box.
- **Multi-arch** — Works on both `linux/amd64` and `linux/arm64` (Apple Silicon, Graviton, etc.).
- **CI/CD ready** — Ideal for GitHub Actions, GitLab CI, Jenkins, or any container-based pipeline.

### When to use it

| Use case | Example |
|---|---|
| Build a Maven project without installing Java | `docker run --rm -v "$PWD":/opt/app softinstigate/graalvm-maven clean package` |
| Compile a GraalVM native image | `docker run --rm -v "$PWD":/opt/app softinstigate/graalvm-maven -Pnative native:compile` |
| Run builds in CI with consistent tooling | Use as a container image in your CI workflow |
| Avoid version conflicts across projects | Different tags for different GraalVM/Maven versions |

## Current versions

- GraalVM: 25-graalce
- Maven: 3.9.11

## Supported platforms and tags

- Architectures: `linux/amd64`, `linux/arm64`
- Registries:
    - Docker Hub: `softinstigate/graalvm-maven`
    - GitHub Container Registry: `ghcr.io/softinstigate/graalvm-maven`
- Useful tags:
    - `latest` (tracks the most recent release)
    - `25-graalce` (current main)
    - Historical examples: `24.0.2-graalce`, `22.0.2-graalce`, `21.0.2-graalce`

Browse tags on:

- Docker Hub: <https://hub.docker.com/r/softinstigate/graalvm-maven/tags>
- GHCR: <https://github.com/SoftInstigate/graalvm-maven-docker/pkgs/container/graalvm-maven>

## Pull the image

```bash
# Docker Hub
docker pull softinstigate/graalvm-maven:25-graalce

# Or GHCR
docker pull ghcr.io/softinstigate/graalvm-maven:25-graalce
```

## How it works

The image is based on `debian:stable-slim` and uses [SDKMAN!](https://sdkman.io) to install GraalVM and Maven. This approach makes version upgrades simple—just change the `ARG` values in the `Dockerfile` and rebuild.

An entrypoint script (`bin/entrypoint.sh`) activates SDKMAN! and delegates to `mvn`, so the image behaves like a standalone Maven command.

## Building a project

The default `ENTRYPOINT` is `mvn`. The working directory is `/opt/app`.

```bash
# Print Maven + Java versions
docker run --rm softinstigate/graalvm-maven --version

# Build a Maven project in the current directory
docker run -it --rm \
    -v "$PWD":/opt/app \
    -v "$HOME"/.m2:/root/.m2 \
    softinstigate/graalvm-maven \
    clean package
```

> Mounting `~/.m2` speeds up builds by reusing your local Maven cache.

## Compiling a native image

Use the [GraalVM Native Build Tools (Maven plugin)](https://graalvm.github.io/native-build-tools/latest/maven-plugin.html/) in your project. Then run:

```bash
# Show native plugin help
docker run -it --rm -v "$PWD":/opt/app softinstigate/graalvm-maven native:help

# Typical native build (adjust for your project)
docker run -it --rm \
    -v "$PWD":/opt/app \
    -v "$HOME"/.m2:/root/.m2 \
    softinstigate/graalvm-maven \
    -Pnative -DskipTests native:compile
```

## Contributing: local development

To build and test the image locally:

```bash
# Build the image locally (no cache)
./bin/build.sh

# Test the image
docker run -it --rm softinstigate/graalvm-maven --version

# Optional: push :latest manually (CI handles official releases)
./bin/push.sh
```

## Release process

- GitHub Actions workflow: `.github/workflows/deploy-image.yml`
- Trigger: push of any git tag
- Output: multi-arch images pushed to Docker Hub and GHCR with:
    - `latest` and the exact git tag name
- Maintainer flow to release a new base version:
    1) Update `ARG JAVA_VERSION` and `ARG MAVEN_VERSION` in `Dockerfile`
    2) Update the versions in this README
    3) Commit and push, then create and push a git tag (e.g. `25-graalce`)

## Entrypoint and environment

- Entrypoint script: `bin/entrypoint.sh`
    - Sources `/root/.bashrc` to activate SDKMAN! before executing Maven
    - Executes `mvn "$@"`
- SDKMAN! config ensures non-interactive installs and stable tool versions:
    - `sdkman_auto_answer=true`
    - `sdkman_auto_selfupdate=false`
    - `sdkman_insecure_ssl=true`

## Troubleshooting

- Maven not found when overriding entrypoint:
    - If you replace the entrypoint with a shell, run `source ~/.bashrc` before using `mvn`.

    ```bash
    docker run -it --rm --entrypoint bash softinstigate/graalvm-maven
    source ~/.bashrc && mvn -v
    ```
- Slow builds or dependency downloads:
    - Ensure you mount your local Maven cache: `-v "$HOME"/.m2:/root/.m2`
- Verify SDKMAN!/Java/Maven inside the container:
  
    ```bash
    docker run -it --rm --entrypoint bash softinstigate/graalvm-maven -lc \
            'source ~/.bashrc; sdk current; java -version; mvn -version'
    ```

## License

This repository is licensed under the [Apache License 2.0](LICENSE).
