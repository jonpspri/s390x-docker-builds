#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" || exit 1

VERSION=${VERSION:-3.1.1}

# TODO:  Form validation of VERSION

BRANCH=$(expr "$VERSION" : '\([0-9]*\.[0-9]*\)')

echo "Build version $VERSION from branch $BRANCH"

docker build -t "swift-build-${VERSION//./}" \
  --build-arg BUILD_BRANCH=${BRANCH} \
  --build-arg RELEASE=swift-${VERSION}-RELEASE \
  -f ./Dockerfile.builder .
