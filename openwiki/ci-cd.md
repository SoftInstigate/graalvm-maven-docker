---
type: Reference
title: CI/CD and Release Process
description: GitHub Actions workflow for building and publishing multi-arch Docker images to Docker Hub and GHCR, including release steps, secrets, and OpenWiki automation.
tags: [ci-cd, github-actions, docker, release, openwiki]
---

# CI/CD and Release Process

## Image deployment workflow

[`.github/workflows/deploy-image.yml`](/.github/workflows/deploy-image.yml) builds and publishes multi-arch Docker images automatically when any git tag is pushed.

### Trigger

```yaml
on:
  push:
    tags:
      - "*"
```

Pushing **any** tag triggers the build. There is no branch filter — the tag itself determines the image tag name.

### Build pipeline

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub Actions
    participant Buildx as Docker Buildx (QEMU)
    participant Hub as Docker Hub
    participant GHCR as ghcr.io

    Dev->>GH: push tag (e.g. 25-graalce)
    GH->>GH: checkout, setup QEMU + Buildx
    GH->>Hub: login (DOCKER_USER / DOCKER_TOKEN)
    GH->>GHCR: login (GITHUB_TOKEN)
    GH->>Buildx: build linux/amd64 + linux/arm64
    Buildx->>Hub: push :latest + :<tag>
    Buildx->>GHCR: push :latest + :<tag>
```

### Output

Each build pushes to **both** registries with two tags:

| Tag pattern | Example |
|-------------|---------|
| `latest` | `softinstigate/graalvm-maven:latest` |
| `<git-tag>` | `softinstigate/graalvm-maven:25-graalce` |

### Required secrets

| Secret | Used by | Purpose |
|--------|---------|---------|
| `DOCKER_USER` | Docker Hub login | Hub username |
| `DOCKER_TOKEN` | Docker Hub login | Hub access token |
| `GITHUB_TOKEN` | GHCR login | Automatic — no manual setup needed |

## Release process (maintainer steps)

1. Update `ARG JAVA_VERSION` and `ARG MAVEN_VERSION` in [`Dockerfile`](/Dockerfile).
2. Update the version table in [`README.md`](/README.md) to match.
3. Commit and push to `main`.
4. Create and push a git tag matching the GraalVM version (e.g. `25-graalce`):
   ```bash
   git tag 25-graalce
   git push origin 25-graalce
   ```
5. GitHub Actions builds and publishes the image automatically.

## OpenWiki automation

[`.github/workflows/openwiki-update.yml`](/.github/workflows/openwiki-update.yml) runs a scheduled OpenWiki documentation refresh:

- **Schedule:** daily at 08:00 UTC (`cron: "0 8 * * *"`)
- **Trigger:** also available via `workflow_dispatch`
- **Process:** checks out the repo, installs OpenWiki globally, runs `openwiki code --update --print`, then opens a PR on the `openwiki/update` branch with any documentation changes.
- **PR scope:** changes under `openwiki/`, `AGENTS.md`, `CLAUDE.md`, and the workflow file itself.

The workflow uses OpenRouter as the LLM provider (configured via `OPENROUTER_API_KEY` secret).

## Relationship to Dockerfile

The CI workflow consumes the Dockerfile as-is — it does not override `ARG` values at build time. This means the version `ARG`s in the Dockerfile are the sole source of truth for what gets installed in the published image.
