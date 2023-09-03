#!/bin/bash

npm install aws-cdk-lib
. ~/.bash_profile
cdk bootstrap aws://$AWS_ACCOUNT_ID/$AWS_REGION
npm install
cdk deploy --app "npx ts-node --prefer-ts-exts ./ci-pipeline.ts" --parameters BUILDXVER=$BUILDX_VER --parameters BASEREPO=$BASE_REPO --parameters BASEIMAGETAG=$BASE_IMAGE_TAG  --parameters GAMEREPO=$GAME_REPO --parameters GAMEASSETSTAG=$GAME_ASSETS_TAG --parameters GAMEARMASSETSTAG=$GAME_ARM_ASSETS_TAG --parameters GAMEAMDASSETSTAG=$GAME_AMD_ASSETS_TAG  --parameters SVNSTK=$SVN_STK --parameters GITHUBSTK=$GITHUB_STK --parameters GITHUBSTKBRANCH=$GITHUB_STK_BRANCH --parameters GAMECODETAG=$GAME_CODE_TAG --parameters GAMEARMCODETAG=$GAME_ARM_CODE_TAG --parameters GAMEAMDCODETAG=$GAME_AMD_CODE_TAG  --parameters GAMESERVERTAG=$GAME_SERVER_TAG --parameters GAMEARMSERVERTAG=$GAME_ARM_SERVER_TAG --parameters GAMEAMDSERVERTAG=$GAME_AMD_SERVER_TAG --parameters S3STKASSETS=$S3_STK_ASSETS --parameters GITHUBOAUTHTOKEN=$GITHUB_OAUTH_TOKEN --parameters GITHUBREPO=$GITHUB_REPO --parameters GITHUBUSER=$GITHUB_USER --parameters GITHUBBRANCH=$GITHUB_BRANCH
