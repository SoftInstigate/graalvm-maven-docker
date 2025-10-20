# graalvm-maven-docker

[![Docker image](https://github.com/SoftInstigate/graalvm-maven-docker/actions/workflows/deploy-image.yml/badge.svg)](https://github.com/SoftInstigate/graalvm-maven-docker/actions/workflows/deploy-image.yml)

Minimal Docker image with [GraalVM](https://graalvm.org) + [Maven](https://maven.apache.org) installed via [SDKMAN!](https://sdkman.io). Use it to build JVM apps and GraalVM native images without installing toolchains locally.

Images are automatically published on Docker Hub and GHCR when a git tag is pushed.

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

## Quick start

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

## Native image builds

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

## Local development of this image

```bash
# Build the image locally (no cache)
./bin/build.sh

# Test the image
docker run -it --rm softinstigate/graalvm-maven --version

# Optional: push :latest manually (CI handles official releases)
./bin/push.sh
```

## CI/CD and release process

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
