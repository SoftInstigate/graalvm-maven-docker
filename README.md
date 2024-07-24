# graalvm-maven-docker

A docker image for [GraalVM](https://graalvm.org) and [Maven](https://maven.apache.org) with native extensions.

It's based on the official [ghcr.io/graalvm/graalvm-community](https://github.com/graalvm/container/tree/master/graalvm-community) image.

Images are automatically published on [Docker Hub](https://hub.docker.com/r/softinstigate/graalvm-maven) when a commit is tagged.

## Pull image

```sh
$ docker pull softinstigate/graalvm-maven
```

## Summary of versions ##

- openjdk 21.0.2 (GraalVM CE 21.0.2+13.1)
- Apache Maven 3.9.8
- native-image 21.0.2

### JDK version:

```sh
$ docker run -it --rm softinstigate/graalvm-maven java --version
openjdk 21.0.2 2024-01-16
OpenJDK Runtime Environment GraalVM CE 21.0.2+13.1 (build 21.0.2+13-jvmci-23.1-b30)
OpenJDK 64-Bit Server VM GraalVM CE 21.0.2+13.1 (build 21.0.2+13-jvmci-23.1-b30, mixed mode, sharing)
```

### Native Image version

```sh
$ docker run -it --rm softinstigate/graalvm-maven native-image --version
native-image 21.0.2 2024-01-16
GraalVM Runtime Environment GraalVM CE 21.0.2+13.1 (build 21.0.2+13-jvmci-23.1-b30)
Substrate VM GraalVM CE 21.0.2+13.1 (build 21.0.2+13, serial gc)
```

### Maven version

```sh
$ docker run -it --rm softinstigate/graalvm-maven mvn --version
Apache Maven 3.9.8 (36645f6c9b5079805ea5009217e36f2cffd34256)
Maven home: /opt/apache-maven-3.9.8
Java version: 21.0.2, vendor: GraalVM Community, runtime: /opt/graalvm-community-java21
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "6.6.32-linuxkit", arch: "amd64", family: "unix"
```

## Run ##

If you want to `mvn clean package` your Java project and use your local `.m2` cache, CD where the pom.xml is located, then:

```sh
$ docker pull softinstigate/graalvm-maven
$ docker run -it --rm \
    -v "$PWD":/opt/app  \
    -v "$HOME"/.m2:/root/.m2 \
    softinstigate/graalvm-maven \
    mvn clean package
```

> The `-v "$HOME"/.m2:/root/.m2` parameter mounts your local `~/.m2` Maven repository as a Docker volume.

## how to build a native image

Use the [Native Maven Plugin](https://graalvm.github.io/native-build-tools/latest/maven-plugin.html/) in your `pom.xml`.
