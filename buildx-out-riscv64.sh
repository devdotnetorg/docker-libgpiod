#!/bin/bash

# Install buildx
# Post https://devdotnet.org/post/sborka-docker-konteinerov-dlya-arm-arhitekturi-ispolzuya-buildx/

# $ chmod +x buildx-out-riscv64.sh
# $ ./buildx-out-riscv64.sh

set -e

echo "Start BUILDX"

# RISC-V (riscv64)

#libgpiod: 2.1.1, 2.1, 2.0.2, 2.0, 1.6.4
#:riscv64/ubuntu 22.04, 20.04
#:riscv64/debian sid
#:riscv64/alpine edge

for LIB_VERSION in 1.6.4 2.0 2.0.2 2.1 2.1.1
do
  # ubuntu, debian
  for IMAGE_VERSION in riscv64/ubuntu:20.04 riscv64/ubuntu:22.04 riscv64/debian:sid
  do
    #
    declare IMAGE_VERSION_2=$(echo "$IMAGE_VERSION" | tr : -)
	IMAGE_VERSION_2=$(echo "$IMAGE_VERSION_2" | tr / -)
    # build
    echo "BUILD version: ${LIB_VERSION} image: ${IMAGE_VERSION}"
    docker buildx build --platform linux/riscv64 -f Dockerfile.ubuntu \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=${IMAGE_VERSION} \
    --target=artifact --output type=local,dest=out/ -t devdotnetorg/libgpiod:${LIB_VERSION}-${IMAGE_VERSION_2} .
    #
  done
  # alpine
  for IMAGE_VERSION in riscv64/alpine:edge
  do
    #
    declare IMAGE_VERSION_2=$(echo "$IMAGE_VERSION" | tr : -)
	IMAGE_VERSION_2=$(echo "$IMAGE_VERSION_2" | tr / -)
    # build
    echo "BUILD version: ${LIB_VERSION} image: ${IMAGE_VERSION}"
    # --platform linux/arm,linux/arm64,linux/amd64
    docker buildx build --platform linux/riscv64 -f Dockerfile.alpine \
    --build-arg LIB_VERSION=${LIB_VERSION} --build-arg IMAGE_VERSION=${IMAGE_VERSION} \
    --target=artifact --output type=local,dest=out/ -t devdotnetorg/libgpiod:${LIB_VERSION}-${IMAGE_VERSION_2} .
    #
  done
done

echo "BUILDX END"
