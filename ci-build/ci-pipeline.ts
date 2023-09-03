#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { PgbPipelineStack } from './pgb-pipeline-stack';

const app = new cdk.App();
new PgbPipelineStack(app, 'PgbPipelineStack', {
  env: { account: process.env.AWS_ACCOUNT_ID, region: process.env.AWS_REGION},
});
