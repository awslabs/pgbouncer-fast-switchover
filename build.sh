#!/bin/bash -x
PGB_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$PGB_REPO:$PGB_TAG
export BASE_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BASE_REPO:$BASE_TAG"
if [ "$PGB_TAG" = "arm64" ]; then
  ARCH="aarch64"
fi
if [ "$PGB_TAG" = "amd64" ]; then
  ARCH="x86_64"
fi
export ARCH=$ARCH
cat Dockerfile.template | envsubst > Dockerfile
cat Dockerfile
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $PGB_IMAGE
#docker build --build-arg BASE_IMAGE=$BASE_IMAGE --build-arg PGB_GITHUB_BRANCH=$PGB_GITHUB_BRANCH --build-arg ARCH=$ARCH -t $PGB_IMAGE .
docker build -t $PGB_IMAGE .
docker push $PGB_IMAGE
