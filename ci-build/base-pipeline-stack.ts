import { Stack, StackProps,CfnParameter,SecretValue} from 'aws-cdk-lib';
import { Construct } from 'constructs'
import * as codecommit from 'aws-cdk-lib/aws-codecommit';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as codebuild from 'aws-cdk-lib/aws-codebuild';
import * as codepipeline from 'aws-cdk-lib/aws-codepipeline';
import * as codepipeline_actions from 'aws-cdk-lib/aws-codepipeline-actions';
import * as iam from "aws-cdk-lib/aws-iam";
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import * as cdk from 'aws-cdk-lib/core';
import * as cfn from 'aws-cdk-lib/aws-cloudformation';

export class BasePipelineStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);
  const BASE_REPO = new CfnParameter(this,"BASEREPO",{type:"String"});
  const BASE_IMAGE_TAG = new CfnParameter(this,"BASEIMAGETAG",{type:"String"});
  const BASE_IMAGE_AMD_TAG = new CfnParameter(this,"BASEIMAGEAMDTAG",{type:"String"});
  const BASE_IMAGE_ARM_TAG = new CfnParameter(this,"BASEIMAGEARMTAG",{type:"String"});
  const GITHUB_OAUTH_TOKEN = new CfnParameter(this,"GITHUBOAUTHTOKEN",{type:"String"});
  const GITHUB_USER = new CfnParameter(this,"GITHUBUSER",{type:"String"});
  const GITHUB_REPO = new CfnParameter(this,"GITHUBREPO",{type:"String"});
  const GITHUB_BRANCH = new CfnParameter(this,"GITHUBBRANCH",{type:"String"});
  const PANDOC_VER = new CfnParameter(this,"PANDOCVER",{type:"String"});
  ///* uncomment when you test the stack and dont want to manually delete the ecr registry 
  const base_registry = new ecr.Repository(this,`base_repo`,{
    repositoryName:BASE_REPO.valueAsString,
    imageScanOnPush: true
  });
  //*/
  //const base_registry = ecr.Repository.fromRepositoryName(this,`base_repo`,BASE_REPO.valueAsString)

  //create a roleARN for codebuild 
  const buildRole = new iam.Role(this, 'BaseCodeBuildDeployRole',{
    roleName: "BaseCodeBuildDeployRole",
    assumedBy: new iam.ServicePrincipal('codebuild.amazonaws.com'),
  });
  
  buildRole.addToPolicy(new iam.PolicyStatement({
    resources: ['*'],
    actions: ['ssm:*'],
  }));

  const githubSecret = new secretsmanager.Secret(this, 'githubSecret', {
    secretObjectValue: {
      token: SecretValue.unsafePlainText(GITHUB_OAUTH_TOKEN.valueAsString)
    },
  });
  const githubOAuthToken = SecretValue.secretsManager(githubSecret.secretArn,{jsonField:'token'});
  new cdk.CfnOutput(this, 'githubOAuthTokenRuntimeOutput1', {
      //value: SecretValue.secretsManager("githubtoken",{jsonField: "token"}).toString()
      value: githubSecret.secretValueFromJson('token').toString()
  });
  new cdk.CfnOutput(this, 'githubOAuthTokenRuntimeOutput2', {
      value: SecretValue.secretsManager(githubSecret.secretArn,{jsonField: "token"}).toString()
  });

  const base_image_arm_build = new codebuild.Project(this, `BaseImageArmBuild`, {
    environment: {privileged:true,buildImage: codebuild.LinuxBuildImage.AMAZON_LINUX_2_ARM_2},
    cache: codebuild.Cache.local(codebuild.LocalCacheMode.DOCKER_LAYER, codebuild.LocalCacheMode.CUSTOM),
    role: buildRole,
    buildSpec: codebuild.BuildSpec.fromObject(
      {
        version: "0.2",
        env: {
          'exported-variables': [
            'AWS_ACCOUNT_ID','AWS_REGION','BASE_REPO','BASE_IMAGE_ARM_TAG'
          ],
        },
        phases: {
          build: {
            commands: [
              `export AWS_ACCOUNT_ID="${this.account}"`,
              `export AWS_REGION="${this.region}"`,
              `export BASE_REPO="${BASE_REPO.valueAsString}"`,
              `export BASE_IMAGE_TAG="${BASE_IMAGE_ARM_TAG.valueAsString}"`,
              `export PANDOC_VER="${PANDOC_VER.valueAsString}"`,
              `export ARCH="${BASE_IMAGE_ARM_TAG.valueAsString}"`,
              `cd baseimage`,
              `chmod +x ./build.sh && ./build.sh`
            ],
          }
        },
        artifacts: {
          files: ['imageDetail.json']
        },
      }
    ),
  });

  const base_image_amd_build = new codebuild.Project(this, `BaseImageAmdBuild`, {
    environment: {privileged:true,buildImage: codebuild.LinuxBuildImage.AMAZON_LINUX_2_3},
    cache: codebuild.Cache.local(codebuild.LocalCacheMode.DOCKER_LAYER, codebuild.LocalCacheMode.CUSTOM),
    role: buildRole,
    buildSpec: codebuild.BuildSpec.fromObject(
      {
        version: "0.2",
        env: {
          'exported-variables': [
            'AWS_ACCOUNT_ID','AWS_REGION','BASE_REPO','BASE_IMAGE_AMD_TAG'
          ],
        },
        phases: {
          build: {
            commands: [
              `export AWS_ACCOUNT_ID="${this.account}"`,
              `export AWS_REGION="${this.region}"`,
              `export BASE_REPO="${BASE_REPO.valueAsString}"`,
              `export BASE_IMAGE_TAG="${BASE_IMAGE_AMD_TAG.valueAsString}"`,
              `export PANDOC_VER="${PANDOC_VER.valueAsString}"`,
              `export ARCH="${BASE_IMAGE_AMD_TAG.valueAsString}"`,
              `cd baseimage`,
              `chmod +x ./build.sh && ./build.sh`
            ],
          }
        },
        artifacts: {
          files: ['imageDetail.json']
        },
      }
    ),
  });

  const base_image_assembly = new codebuild.Project(this, `BaseImageAmdBuildAssembly`, {
    environment: {privileged:true,buildImage: codebuild.LinuxBuildImage.AMAZON_LINUX_2_ARM_2},
    cache: codebuild.Cache.local(codebuild.LocalCacheMode.DOCKER_LAYER, codebuild.LocalCacheMode.CUSTOM),
    role: buildRole,
    buildSpec: codebuild.BuildSpec.fromObject(
      {
        version: "0.2",
        env: {
          'exported-variables': [
            'AWS_ACCOUNT_ID','AWS_REGION','BASE_REPO','BASE_IMAGE_AMD_TAG','BASE_IMAGE_ARM_TAG','BASE_IMAGE_TAG'
          ],
        },
        phases: {
          build: {
            commands: [
              `export AWS_ACCOUNT_ID="${this.account}"`,
              `export AWS_REGION="${this.region}"`,
              `export BASE_REPO="${BASE_REPO.valueAsString}"`,
              `export BASE_IMAGE_AMD_TAG="${BASE_IMAGE_AMD_TAG.valueAsString}"`,
              `export BASE_IMAGE_ARM_TAG="${BASE_IMAGE_ARM_TAG.valueAsString}"`,
              `export BASE_IMAGE_TAG="${BASE_IMAGE_TAG.valueAsString}"`,
              `cd baseimage`,
              `chmod +x ./assemble_multiarch_image.sh && ./assemble_multiarch_image.sh`
            ],
          }
        },
        artifacts: {
          files: ['imageDetail.json']
        },
      }
    ),
  });
    
  //we allow the buildProject principal to push images to ecr
  base_registry.grantPullPush(base_image_arm_build.grantPrincipal);
  base_registry.grantPullPush(base_image_amd_build.grantPrincipal);
  base_registry.grantPullPush(base_image_assembly.grantPrincipal);

  // here we define our pipeline and put together the assembly line
  const sourceOutput = new codepipeline.Artifact();
  const basebuildpipeline = new codepipeline.Pipeline(this,`BuildBasePipeline`);
  basebuildpipeline.addStage({
    stageName: 'Source',
    actions: [
      new codepipeline_actions.GitHubSourceAction({
        actionName: 'GitHub_Source',
        owner: GITHUB_USER.valueAsString,
        repo: GITHUB_REPO.valueAsString,
        branch: GITHUB_BRANCH.valueAsString,
        output: sourceOutput,
        oauthToken: SecretValue.secretsManager("githubtoken",{jsonField: "token"}),
        trigger: codepipeline_actions.GitHubTrigger.WEBHOOK,
        //oauthToken: SecretValue.unsafePlainText(GITHUB_OAUTH_TOKEN.valueAsString)
      })
      ]
  });

  basebuildpipeline.addStage({
    stageName: 'BaseImageBuild',
    actions: [
      new codepipeline_actions.CodeBuildAction({
        actionName: 'BaseImageArmBuildX',
        input: sourceOutput,
        runOrder: 1,
        project: base_image_arm_build
      }),
      new codepipeline_actions.CodeBuildAction({
        actionName: 'BaseImageAmdBuildX',
        input: sourceOutput,
        runOrder: 1,
        project: base_image_amd_build
      }),
      new codepipeline_actions.CodeBuildAction({
          actionName: 'AssembleBaseBuilds',
          input: sourceOutput,
          runOrder: 2,
          project: base_image_assembly
        })
    ]
  });
  }
}
