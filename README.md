# graalvm-maven-docker

A docker image for [GraalVM](https://graalvm.org) and [Maven](https://maven.apache.org) built with [sdkman](https://sdkman.io)

It also installs `native-image`

## Versions ##

- GraalVM: 21.1.0.r16-grl
- Maven: 3.6.3

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

Use the [Native Image Maven Plugin](https://www.graalvm.org/reference-manual/native-image/NativeImageMavenPlugin/) in your `pom.xml`.