#!/bin/bash

# Install buildx
# Post https://devdotnet.org/post/sborka-docker-konteinerov-dlya-arm-arhitekturi-ispolzuya-buildx/

# $ chmod +x buildx-out.sh
# $ ./buildx-out.sh

set -e

echo "Start BUILDX"

#libgpiod: 2.0.1, 2.0, 1.6.4
#:ubuntu 23.04, 22.10, 22.04, 20.04, 18.04
#:debian 12, 11
#:alpine 3.18, 3.17, 3.16, 3.15

for LIB_VERSION in 2.0.1, 2.0, 1.6.4
do
  # ubuntu, debian
  for IMAGE_VERSION in ubuntu:23.04 ubuntu:22.10 ubuntu:22.04 ubuntu:20.04 ubuntu:18.04 debian:12 debian:11
  do
    #
    declare IMAGE_VERSION_2=$(echo "$IMAGE_VERSION" | tr : -)
    # build
    echo "BUILD version: ${LIB_VERSION} image: ${IMAGE_VERSION}"
    docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.ubuntu \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=${IMAGE_VERSION} \
    --target=artifact --output type=local,dest=out/ -t devdotnetorg/libgpiod:${LIB_VERSION}-${IMAGE_VERSION_2} .
    #
  done
  # alpine
  for IMAGE_VERSION in alpine:3.18 alpine:3.17 alpine:3.16 alpine:3.15
  do
    #
    declare IMAGE_VERSION_2=$(echo "$IMAGE_VERSION" | tr : -)
    # build
    echo "BUILD version: ${LIB_VERSION} image: ${IMAGE_VERSION}"
    docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.alpine \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=${IMAGE_VERSION} \
    --target=artifact --output type=local,dest=out/ -t devdotnetorg/libgpiod:${LIB_VERSION}-${IMAGE_VERSION_2} .
    #
  done
done

echo "BUILDX END"
