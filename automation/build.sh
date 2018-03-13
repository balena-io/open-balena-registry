#!/bin/sh
set -e

# Input is:
# - IMAGE_NAME: the repo to push the image to, eg. resin/repository-name
# - BRANCH_NAME: eg. fix-some-bug

VERSION=$(git describe --tags)
REVISION=$(git rev-parse --short HEAD)
BRANCH=$(echo $BRANCH_NAME | sed 's/[^a-z0-9A-Z_.-]/-/g')

# Try pulling the old build first for caching purposes.
docker pull ${IMAGE_NAME}:${BRANCH} || docker pull ${IMAGE_NAME}:master || true

# Build and tag
docker build --pull --tag ${IMAGE_NAME}:${REVISION} .
docker tag ${IMAGE_NAME}:${REVISION} ${IMAGE_NAME}:${BRANCH}
docker tag ${IMAGE_NAME}:${REVISION} ${IMAGE_NAME}:${VERSION}

# Push the images
docker push ${IMAGE_NAME}:${REVISION}
docker push ${IMAGE_NAME}:${BRANCH}
docker push ${IMAGE_NAME}:${VERSION}
