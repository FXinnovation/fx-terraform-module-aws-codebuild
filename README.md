# terraform-module-multi-template

Template repository for public terraform modules

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 2.0 |
| random | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |
| random | >= 2.1 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) |
| [aws_codebuild_source_credential](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) |
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) |
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) |
| [random_string](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_log\_bucket\_name | Name of the S3 bucket where s3 access log will be sent to | `string` | `"codebuild-log-bucket"` | no |
| artifact\_location | Location of artifact. Applies only for artifact of type S3 | `string` | `""` | no |
| artifact\_type | The build output artifact's type. Valid values for this parameter are: CODEPIPELINE, NO\_ARTIFACTS or S3 | `string` | `"CODEPIPELINE"` | no |
| aws\_region | (Optional) AWS Region, e.g. us-east-1. Used as CodeBuild ENV variable when building Docker images. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html | `string` | `"ca-central-1"` | no |
| badge\_enabled | Generates a publicly-accessible URL for the projects build badge. Available as badge\_url attribute when enabled | `bool` | `false` | no |
| build\_compute\_type | Instance type of the build instance | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| build\_image | Docker image for build environment, e.g. 'aws/codebuild/standard:2.0' or 'aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0'. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html | `string` | `"aws/codebuild/standard:2.0"` | no |
| build\_timeout | How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed | `number` | `60` | no |
| build\_type | The type of build environment, e.g. 'LINUX\_CONTAINER' or 'WINDOWS\_CONTAINER' | `string` | `"LINUX_CONTAINER"` | no |
| buildspec | Optional buildspec declaration to use for building the project | `string` | `""` | no |
| cache\_bucket\_name | Name of the S3 bucket where s3 is used for cache | `string` | `"codebuild-cache-bucket"` | no |
| cache\_bucket\_suffix\_enabled | The cache bucket generates a random 13 character string to generate a unique bucket name. If set to false it uses terraform-null-label's id value. It only works when cache\_type is 'S3 | `bool` | `true` | no |
| cache\_expiration\_days | How many days should the build cache be kept. It only works when cache\_type is 'S3' | `number` | `7` | no |
| cache\_type | The type of storage that will be used for the AWS CodeBuild project cache. Valid values: NO\_CACHE, LOCAL, and S3.  Defaults to NO\_CACHE.  If cache\_type is S3, it will create an S3 bucket for storing codebuild cache inside | `string` | `"NO_CACHE"` | no |
| codebuild\_iam\_policy\_name | name fot the default Iam policy codebuild | `string` | `"codebuild"` | no |
| codebuild\_project\_name | name fot the codebuild project | `string` | `"codebuild-project"` | no |
| encryption\_enabled | When set to 'true' the resource will have AES256 encryption enabled by default | `bool` | `false` | no |
| environment\_variables | A list of maps, that contain both the key 'name' and the key 'value' to be used as additional environment variables for the build | <pre>list(object(<br>    {<br>      name  = string<br>      value = string<br>  }))</pre> | <pre>[<br>  {<br>    "name": "NO_ADDITIONAL_BUILD_VARS",<br>    "value": "TRUE"<br>  }<br>]</pre> | no |
| extra\_permissions | List of action strings which will be added to IAM service account permissions. | `list(any)` | `[]` | no |
| fetch\_git\_submodules | If set to true, fetches Git submodules for the AWS CodeBuild build project. | `bool` | `false` | no |
| git\_clone\_depth | Truncate git history to this many commits. | `number` | `null` | no |
| github\_token | (Optional) GitHub auth token environment variable (`GITHUB_TOKEN`) | `string` | `""` | no |
| image\_repo\_name | (Optional) ECR repository name to store the Docker image built by this module. Used as CodeBuild ENV variable when building Docker images. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html | `string` | `"UNSET"` | no |
| image\_tag | (Optional) Docker image tag in the ECR repository, e.g. 'latest'. Used as CodeBuild ENV variable when building Docker images. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/sample-docker.html | `string` | `"latest"` | no |
| local\_cache\_modes | Specifies settings that AWS CodeBuild uses to store and reuse build dependencies. Valid values: LOCAL\_SOURCE\_CACHE, LOCAL\_DOCKER\_LAYER\_CACHE, and LOCAL\_CUSTOM\_CACHE | `list(string)` | `[]` | no |
| logging\_prefix | Can be blank, but is the path to your logs in access bucket | `string` | `null` | no |
| logs\_config | Configuration for the builds to store log data to CloudWatch or S3. | `any` | `{}` | no |
| private\_repository | Set to true to login into private repository with credentials supplied in source\_credential variable. | `bool` | `false` | no |
| privileged\_mode | (Optional) If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images | `bool` | `false` | no |
| report\_build\_status | Set to true to report the status of a build's start and finish to your source provider. This option is only valid when the source\_type is BITBUCKET or GITHUB | `bool` | `false` | no |
| secondary\_artifact\_encryption\_enabled | Set to true to enable encryption on the secondary artifact bucket | `bool` | `false` | no |
| secondary\_artifact\_identifier | Secondary artifact identifier. Must match the identifier in the build spec | `string` | `null` | no |
| secondary\_artifact\_location | Location of secondary artifact. Must be an S3 reference | `string` | `null` | no |
| secondary\_sources | (Optional) secondary source for the codebuild project in addition to the primary location | <pre>list(object(<br>    {<br>      git_clone_depth     = number<br>      location            = string<br>      source_identifier   = string<br>      type                = string<br>      fetch_submodules    = bool<br>      insecure_ssl        = bool<br>      report_build_status = bool<br>  }))</pre> | `[]` | no |
| source\_credential\_auth\_type | The type of authentication used to connect to a GitHub, GitHub Enterprise, or Bitbucket repository. | `string` | `"PERSONAL_ACCESS_TOKEN"` | no |
| source\_credential\_server\_type | The source provider used for this project. | `string` | `"GITHUB"` | no |
| source\_credential\_token | For GitHub or GitHub Enterprise, this is the personal access token. For Bitbucket, this is the app password. | `string` | `""` | no |
| source\_credential\_user\_name | The Bitbucket username when the authType is BASIC\_AUTH. This parameter is not valid for other types of source providers or connections. | `string` | `""` | no |
| source\_location | The location of the source code from git or s3 | `string` | `""` | no |
| source\_type | The type of repository that contains the source code to be built. Valid values for this parameter are: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB\_ENTERPRISE, BITBUCKET or S3 | `string` | `"CODEPIPELINE"` | no |
| source\_version | A version of the build input to be built for this project. If not specified, the latest version is used. | `string` | `""` | no |
| tags | Tags to be merged with all resources of this module. | `map(string)` | `{}` | no |
| versioning\_enabled | A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket | `bool` | `true` | no |
| vpc\_config | Configuration for the builds to run inside a VPC. | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| badge\_url | The URL of the build badge when badge\_enabled is enabled |
| cache\_bucket\_arn | Cache S3 bucket ARN |
| cache\_bucket\_name | Cache S3 bucket name |
| project\_arn | Project ARN |
| project\_id | Project ID |
| project\_name | Project name |
| role\_arn | IAM Role ARN |
| role\_id | IAM Role ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Versioning
This repository follows [Semantic Versioning 2.0.0](https://semver.org/)

## Git Hooks
This repository uses [pre-commit](https://pre-commit.com/) hooks.
