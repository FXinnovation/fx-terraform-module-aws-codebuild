# Default example

## Usage

```
# terraform init
# terraform apply
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | ~> 2 |
| aws | ~> 2.57 |

## Providers

No provider.

## Modules

| Name | Source | Version |
|------|--------|---------|
| codebuild | ../../ |  |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_key | Credentials: AWS access key. | `string` | n/a | yes |
| secret\_key | Credentials: AWS secret key. Pass this as a variable, never write password in the code. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| badge\_url | The URL of the build badge when badge\_enabled is enabled |
| cache\_bucket\_arn | Cache S3 bucket ARN |
| cache\_bucket\_name | Cache S3 bucket name |
| project\_id | Project ID |
| project\_name | Project name |
| role\_arn | IAM Role ARN |
| role\_id | IAM Role ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
