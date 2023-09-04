#!/bin/bash -x

BASE_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BASE_REPO:$BASE_IMAGE_TAG
BASE_ARM_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BASE_REPO:$BASE_IMAGE_ARM_TAG
BASE_AMD_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BASE_REPO:$BASE_IMAGE_AMD_TAG
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $BASE_IMAGE

docker manifest create $BASE_IMAGE --amend $BASE_ARM_IMAGE --amend $BASE_AMD_IMAGE
docker manifest push $BASE_IMAGE
