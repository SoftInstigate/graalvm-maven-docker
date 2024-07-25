# graalvm-maven-docker

[![Docker image](https://github.com/SoftInstigate/graalvm-maven-docker/actions/workflows/deploy-image.yml/badge.svg)](https://github.com/SoftInstigate/graalvm-maven-docker/actions/workflows/deploy-image.yml)

A docker image for [GraalVM](https://graalvm.org) and [Maven](https://maven.apache.org) built with [sdkman](https://sdkman.io)

It also installs `native-image`

Images are automatically published on [Docker Hub](https://hub.docker.com/r/softinstigate/graalvm-maven) when commit is tagged.

## Versions ##

- GraalVM: 21.0.2-graal
- Maven: 3.9.1

## Pull image

```bash
$ docker pull softinstigate/graalvm-maven
```

## Run ##

The default `ENTRYPOINT` for this image is `mvn`.

If you want to `mvn clean install` your Java project, CD where the pom.xml is located, then:

```bash
$ docker pull softinstigate/graalvm-maven
$ docker run -it --rm \
    -v "$PWD":/opt/app  \
    -v "$HOME"/.m2:/root/.m2 \
    softinstigate/graalvm-maven \
    clean package
```

> The `-v "$HOME"/.m2:/root/.m2` parameter mounts your local `~/.m2` Maven repository as a Docker volume.

## how to build a native image

Use the [Native Maven Plugin](https://graalvm.github.io/native-build-tools/latest/maven-plugin.html/) in your `pom.xml`.
