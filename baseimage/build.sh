#!/bin/bash -x
BASE_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BASE_REPO:$BASE_IMAGE_TAG
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $BASE_IMAGE
if [ "$ARCH" = "arm64" ]; then
  AWSCLIARCH="aarch64"
fi
if [ "$ARCH" = "amd64" ]; then
  AWSCLIARCH="x86_64"
fi
docker build --build-arg PANDOC_VER=$PANDOC_VER --build-arg ARCH=$ARCH --build-arg AWSCLIARCH=$AWSCLIARCH -t $BASE_IMAGE .
docker push $BASE_IMAGE
