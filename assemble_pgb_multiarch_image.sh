#!/bin/bash -x

PGB_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$PGB_REPO:$PGB_TAG
PGB_ARM_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$PGB_REPO:$PGB_ARM_TAG
PGB_AMD_IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$PGB_REPO:$PGB_AMD_TAG
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $PGB_IMAGE

docker manifest create $PGB_IMAGE --amend $PGB_ARM_IMAGE --amend $PGB_AMD_IMAGE
docker manifest push $PGB_IMAGE
