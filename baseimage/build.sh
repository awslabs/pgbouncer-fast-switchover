#!/bin/bash -x
BASE_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BASE_REPO:$BASE_IMAGE_TAG
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $BASE_IMAGE

docker build --build-arg PANDOC_VER=$PANDOC_VER --build-arg ARCH=$ARCH -t $BASE_IMAGE .
docker push $BASE_IMAGE
