#!/bin/bash

# Install buildx
# Post https://devdotnet.org/post/sborka-docker-konteinerov-dlya-arm-arhitekturi-ispolzuya-buildx/

# $ chmod +x buildx-tags-get-bin.sh
# $ ./buildx-tags-get-bin.sh

set -e

echo "Start BUILDX"

#libgpiod
#2.0.1
#2.0
#1.6.4
#1.6.3

#:ubuntu
#23.04
#22.10
#22.04
#20.04
#18.04
#16.04

#:debian
#latest debian:12
#12
#11
#10

#:alpine
#latest alpine:3.18
#3.18
#3.17
#3.16
#3.15

docker buildx build --platform linux/amd64 -f Dockerfile.ubuntu --build-arg LIB_VERSION="2.0.1" --build-arg \
 IMAGE_VERSION=ubuntu:22.04 --target=artifact --output type=local,dest=out/ \
 -t devdotnetorg/libgpiod:2.0.1-ubuntu-22.04 .

docker buildx build --platform linux/amd64 -f Dockerfile.alpine --build-arg LIB_VERSION="2.0.1" --build-arg \
 IMAGE_VERSION=alpine:3.18 --target=artifact --output type=local,dest=out/ \
 -t devdotnetorg/libgpiod:2.0.1-alpine-3.18 .
 

echo "BUILDX END"
