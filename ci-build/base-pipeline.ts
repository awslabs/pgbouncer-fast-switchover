#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { BasePipelineStack } from './base-pipeline-stack';

const app = new cdk.App();
new BasePipelineStack(app, 'BasePipelineStack', {
  env: { account: process.env.AWS_ACCOUNT_ID, region: process.env.AWS_REGION},
});
