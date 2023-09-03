#!/bin/bash

npm install aws-cdk-lib
. ~/.bash_profile
cdk bootstrap aws://$AWS_ACCOUNT_ID/$AWS_REGION
npm install
cdk deploy --app "npx ts-node --prefer-ts-exts ./ci-pipeline.ts" --parameters BASEREPO=$BASE_REPO --parameters BASETAG=$BASE_TAG  --parameters PGBREPO=$PGB_REPO --parameters PGBTAG=$PGB_TAG --parameters PGBARMTAG=$PGB_ARM_TAG --parameters PGBAMDTAG=$PGB_AMD_TAG  --parameters PGBGITHUBBRANCH=$PGB_GITHUB_BRANCH --parameters GITHUBOAUTHTOKEN=$GITHUB_OAUTH_TOKEN --parameters GITHUBREPO=$GITHUB_REPO --parameters GITHUBUSER=$GITHUB_USER --parameters GITHUBBRANCH=$GITHUB_BRANCH
