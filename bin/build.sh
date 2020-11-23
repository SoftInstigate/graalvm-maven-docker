#!/bin/bash

docker build --no-cache . -t softinstigate/graalvm-maven
docker tag softinstigate/graalvm-maven:latest softinstigate/graalvm-maven:latest