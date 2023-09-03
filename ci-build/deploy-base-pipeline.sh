#!/bin/bash

npm install aws-cdk-lib
. ~/.bash_profile
cdk bootstrap aws://$AWS_ACCOUNT_ID/$AWS_REGION
npm install
cdk deploy --app "npx ts-node --prefer-ts-exts ./base-pipeline.ts"  --parameters BUILDXVER=$BUILDX_VER --parameters BASEREPO=$BASE_REPO --parameters BASEIMAGETAG=$BASE_IMAGE_TAG --parameters BASEIMAGEAMDTAG=$BASE_IMAGE_AMD_TAG --parameters BASEIMAGEARMTAG=$BASE_IMAGE_ARM_TAG --parameters GITHUBOAUTHTOKEN=$GITHUB_OAUTH_TOKEN --parameters GITHUBREPO=$GITHUB_REPO --parameters GITHUBUSER=$GITHUB_USER --parameters GITHUBBRANCH=$GITHUB_BRANCH
