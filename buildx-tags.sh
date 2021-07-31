#!/bin/bash

# Install buildx
# $ export DOCKER_BUILDKIT=1
# $ docker build --platform=local -o . git://github.com/docker/buildx
# $ mkdir -p ~/.docker/cli-plugins
# $ mv buildx ~/.docker/cli-plugins/docker-buildx

# Execute each time before building with buildx
# $ export DOCKER_BUILDKIT=1
# $ docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
# $ cat /proc/sys/fs/binfmt_misc/qemu-aarch64

# $ chmod +x buildx-tags.sh
# $ ./buildx-tags.sh

set -e

echo "Start BUILDX"

# LIBGPIOD_VERSION=1.6.3

#Alpine
#------
#:amd64
docker buildx build --platform linux/amd64 -f Dockerfile.alpine --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-amd64 . --push
#:aarch64
docker buildx build --platform linux/arm64 -f Dockerfile.alpine --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-aarch64 . --push
#:armhf
docker buildx build --platform linux/arm -f Dockerfile.alpine --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-armhf . --push
#:all platform
docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.alpine --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3 . --push
#:latest
docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.alpine --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:latest . --push

#Ubuntu 20.04 LTS (Focal Fossa)
#------
#:amd64
docker buildx build --platform linux/amd64 -f Dockerfile.focal --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-focal-amd64 . --push
#:aarch64
docker buildx build --platform linux/arm64 -f Dockerfile.focal --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-focal-aarch64 . --push
#:armhf
docker buildx build --platform linux/arm -f Dockerfile.focal --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-focal-armhf . --push
#:all platform
docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.focal --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-focal . --push

#Debian 10 buster 
#------
#:amd64
#docker buildx build --platform linux/amd64 -f Dockerfile.buster --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-buster-amd64 . --push
#:aarch64
#docker buildx build --platform linux/arm64 -f Dockerfile.buster --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-buster-aarch64 . --push
#:armhf
#docker buildx build --platform linux/arm -f Dockerfile.buster --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-buster-armhf . --push
#:all platform
#docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.buster --build-arg LIBGPIOD_VERSION=1.6.3 -t devdotnetorg/libgpiod:1.6.3-buster . --push

echo "BUILDX END"
