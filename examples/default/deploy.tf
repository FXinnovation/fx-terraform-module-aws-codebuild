provider "aws" {
  region = var.region
}

module "codebuild" {
  source = "../../"
  region = "us-east-2"

  namespace = "eg"

  stage = "test"

  name = "codebuild-test"

  cache_bucket_suffix_enabled = false

  cache_expiration_days = 7

  cache_type = "S3"

}
