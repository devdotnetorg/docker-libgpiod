#!/bin/bash

# Install buildx
# Post https://devdotnet.org/post/sborka-docker-konteinerov-dlya-arm-arhitekturi-ispolzuya-buildx/

# $ chmod +x buildx-tags.sh
# $ ./buildx-tags.sh

set -e

echo "Start BUILDX"

for LIB_VERSION in 1.6.4 2.1.2
do
	echo "BUILD version: ${LIB_VERSION} Ubuntu 24.04"
	#Ubuntu 24.04 LTS
	#------
    docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.ubuntu \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=ubuntu:24.04 \
    -t devdotnetorg/libgpiod:${LIB_VERSION}-ubuntu-24.04 . --push
	#
    docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.ubuntu \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=ubuntu:24.04 \
    -t devdotnetorg/libgpiod:${LIB_VERSION}-ubuntu . --push
	echo "BUILD version: ${LIB_VERSION} Alpine 3.20"
	#Alpine 3.20
	#------
	docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.alpine \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=alpine:3.20 \
    -t devdotnetorg/libgpiod:${LIB_VERSION}-alpine-3.20 . --push
	#
	docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.alpine \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=alpine:3.20 \
    -t devdotnetorg/libgpiod:${LIB_VERSION}-alpine . --push
	#:latest-version
	docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.alpine \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=alpine:3.20 \
    -t devdotnetorg/libgpiod:${LIB_VERSION} . --push
done

#:latest
LIB_VERSION=2.1.2
#

echo "BUILD version: ${LIB_VERSION} :latest"
docker buildx build --platform linux/arm,linux/arm64,linux/amd64 -f Dockerfile.alpine \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=alpine:3.20 \
    -t devdotnetorg/libgpiod . --push

# RISC-V (riscv64)
for LIB_VERSION in 1.6.4 2.1.2
do
	echo "BUILD version: ${LIB_VERSION} riscv64/ubuntu:22.04"
	#Ubuntu 22.04 LTS (Jammy Jellyfish)
	#------
    docker buildx build --platform linux/riscv64 -f Dockerfile.ubuntu \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=riscv64/ubuntu:22.04 \
    -t devdotnetorg/libgpiod:${LIB_VERSION}-ubuntu-22.04-riscv64 . --push
    docker buildx build --platform linux/riscv64 -f Dockerfile.ubuntu \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=riscv64/ubuntu:22.04 \
    -t devdotnetorg/libgpiod:${LIB_VERSION}-ubuntu-riscv64 . --push
	echo "BUILD version: ${LIB_VERSION} riscv64/alpine:edge"
	#Alpine edge
	#------
	docker buildx build --platform linux/riscv64 -f Dockerfile.alpine \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=riscv64/alpine:edge \
    -t devdotnetorg/libgpiod:${LIB_VERSION}-alpine-edge-riscv64 . --push
	#
	docker buildx build --platform linux/riscv64 -f Dockerfile.alpine \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=riscv64/alpine:edge \
    -t devdotnetorg/libgpiod:${LIB_VERSION}-alpine-riscv64 . --push
done

#:latest-riscv64
LIB_VERSION=2.1.2
#
docker buildx build --platform linux/riscv64 -f Dockerfile.alpine \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=riscv64/alpine:edge \
    -t devdotnetorg/libgpiod:${LIB_VERSION}-riscv64 . --push

docker buildx build --platform linux/riscv64 -f Dockerfile.alpine \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=riscv64/alpine:edge \
    -t devdotnetorg/libgpiod:riscv64 . --push

echo "BUILDX END"
