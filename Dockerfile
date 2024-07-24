FROM ghcr.io/graalvm/graalvm-community:21.0.2

LABEL maintainer="SoftInstigate <info@softinstigate.com>"

ARG MAVEN_VERSION="3.9.8"

# Download and install Maven
RUN curl -o "/tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz" "https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz" && \
    tar xzf "/tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz" -C /opt && \
    ln -s "/opt/apache-maven-${MAVEN_VERSION}/bin/mvn" /usr/bin/mvn && \
    rm "/tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
