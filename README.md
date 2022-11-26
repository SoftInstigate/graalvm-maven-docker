# graalvm-maven-docker

A docker image for [GraalVM](https://graalvm.org) and [Maven](https://maven.apache.org) built with [sdkman](https://sdkman.io)

It also installs `native-image`

## Versions ##

- GraalVM: 22.3.r17
- Maven: 3.8.6

## Pull image

```bash
$ docker pull ghcr.io/softinstigate/graalvm-maven-docker
```

## Run ##

The default `ENTRYPOINT` for this image is `mvn`.

If you want to `mvn clean install` your Java project, CD where the pom.xml is located, then:

```bash
$ docker pull ghcr.io/softinstigate/graalvm-maven-docker
$ docker run -it --rm \
    -v "$PWD":/opt/app  \
    -v "$HOME"/.m2:/root/.m2 \
    softinstigate/graalvm-maven-docker \
    clean package
```

> The `-v "$HOME"/.m2:/root/.m2` parameter mounts your local `~/.m2` Maven repository as a Docker volume.

## how to build a native image

Use the [Native Maven Plugin](https://graalvm.github.io/native-build-tools/latest/maven-plugin.html/) in your `pom.xml`.
