#####
# Locals
#####

locals {
  cache_bucket_name = var.cache_bucket_name
  ## Clean up the bucket name to use only hyphens, and trim its length to 63 characters.
  ## As per https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
  cache_bucket_name_normalised = substr(
    join("-", split("_", lower(local.cache_bucket_name))),
    0,
    min(length(local.cache_bucket_name), 63),
  )
  s3_cache_enabled = var.cache_type == "S3"
  cache_options = {
    "S3" = {
      type     = "S3"
      location = local.s3_cache_enabled ? join("", aws_s3_bucket.cache_bucket.*.bucket) : "none"

    },
    "LOCAL" = {
      type  = "LOCAL"
      modes = var.local_cache_modes
    },
    "NO_CACHE" = {
      type = "NO_CACHE"
    }
  }
  # Final Map Selected from above
  cache = local.cache_options[var.cache_type]
  labels = {
    managed-by = "terraform"
    name       = "registry-sync"
  }
  tags = {
    managed-by = "terraform"
    name       = "registry-sync"
  }
  annotations = {}
}

#####
# s3 cache
####

resource "aws_s3_bucket" "cache_bucket" {
  #bridgecrew:skip=BC_AWS_S3_13:Skipping `Enable S3 Bucket Logging` check until bridgecrew will support dynamic blocks (https://github.com/bridgecrewio/checkov/issues/776).
  #bridgecrew:skip=BC_AWS_S3_14:Skipping `Ensure all data stored in the S3 bucket is securely encrypted at rest` check until bridgecrew will support dynamic blocks (https://github.com/bridgecrewio/checkov/issues/776).
  #bridgecrew:skip=CKV_AWS_52:Skipping `Ensure S3 bucket has MFA delete enabled` due to issue in terraform (https://github.com/hashicorp/terraform-provider-aws/issues/629).
  count         = local.s3_cache_enabled ? 1 : 0
  bucket        = local.cache_bucket_name_normalised
  acl           = "private"
  force_destroy = true
  tags = merge(
    var.tags,
    local.tags,
  )

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "logging" {
    for_each = var.access_log_bucket_name != "" ? [1] : []
    content {
      target_bucket = var.access_log_bucket_name
      target_prefix = "logs/${var.logging_prefix}/"
    }
  }

  lifecycle_rule {
    id      = "codebuildcache"
    enabled = true

    prefix = "/"
    tags = merge(
      var.tags,
      local.tags,
    )

    expiration {
      days = var.cache_expiration_days
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.encryption_enabled ? ["true"] : []

    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }
}

#####
# Random
#####

resource "random_string" "bucket_prefix" {
  length  = 12
  number  = false
  upper   = false
  special = false
  lower   = true
}

#####
# IamRoles
####

resource "aws_iam_role" "default" {
  name                  = "code-build"
  assume_role_policy    = data.aws_iam_policy_document.role.json
  force_detach_policies = true
  tags = merge(
    var.tags,
    local.tags,
  )
}


resource "aws_iam_policy" "default" {
  name   = var.codebuild_iam_policy_name
  path   = "/service-role/"
  policy = data.aws_iam_policy_document.combined_permissions.json
}

resource "aws_iam_policy" "default_cache_bucket" {
  count  = local.s3_cache_enabled ? 1 : 0
  name   = "default-cache-bucket"
  path   = "/service-role/"
  policy = join("", data.aws_iam_policy_document.permissions_cache_bucket.*.json)
}

resource "aws_iam_role_policy_attachment" "default" {
  policy_arn = join("", aws_iam_policy.default.*.arn)
  role       = join("", aws_iam_role.default.*.id)
}

resource "aws_iam_role_policy_attachment" "default_cache_bucket" {
  count      = local.s3_cache_enabled ? 1 : 0
  policy_arn = join("", aws_iam_policy.default_cache_bucket.*.arn)
  role       = join("", aws_iam_role.default.*.id)
}

#####
# Code Build
#####

resource "aws_codebuild_source_credential" "authorization" {
  count       = var.private_repository ? 1 : 0
  auth_type   = var.source_credential_auth_type
  server_type = var.source_credential_server_type
  token       = var.source_credential_token
  user_name   = var.source_credential_user_name
}

resource "aws_codebuild_project" "default" {
  name           = var.codebuild_project_name
  service_role   = join("", aws_iam_role.default.*.arn)
  badge_enabled  = var.badge_enabled
  build_timeout  = var.build_timeout
  source_version = var.source_version != "" ? var.source_version : null
  tags = merge(
    var.tags,
    local.tags,
  )

  artifacts {
    type     = var.artifact_type
    location = var.artifact_location
  }

  # Since the output type is restricted to S3 by the provider (this appears to
  # be an bug in AWS, rather than an architectural decision; see this issue for
  # discussion: https://github.com/hashicorp/terraform-provider-aws/pull/9652),
  # this cannot be a CodePipeline output. Otherwise, _all_ of the artifacts
  # would need to be secondary if there were more than one. For reference, see
  # https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeBuild.html#action-reference-CodeBuild-config.
  dynamic "secondary_artifacts" {
    for_each = var.secondary_artifact_location != null ? [1] : []
    content {
      type                = "S3"
      location            = var.secondary_artifact_location
      artifact_identifier = var.secondary_artifact_identifier
      encryption_disabled = !var.secondary_artifact_encryption_enabled
      # According to AWS documention, in order to have the artifacts written
      # to the root of the bucket, the 'namespace_type' should be 'NONE'
      # (which is the default), 'name' should be '/', and 'path' should be
      # empty. For reference, see https://docs.aws.amazon.com/codebuild/latest/APIReference/API_ProjectArtifacts.html.
      # However, I was unable to get this to deploy to the root of the bucket
      # unless path was also set to '/'.
      path = "/"
      name = "/"
    }
  }

  cache {
    type     = lookup(local.cache, "type", null)
    location = lookup(local.cache, "location", null)
    modes    = lookup(local.cache, "modes", null)
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.build_image
    type            = var.build_type
    privileged_mode = var.privileged_mode
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
  }

  source {
    buildspec           = var.buildspec
    type                = var.source_type
    location            = var.source_location
    report_build_status = var.report_build_status
    git_clone_depth     = var.git_clone_depth != null ? var.git_clone_depth : null

    dynamic "auth" {
      for_each = var.private_repository ? [""] : []
      content {
        type     = "OAUTH"
        resource = join("", aws_codebuild_source_credential.authorization.*.id)
      }
    }

    dynamic "git_submodules_config" {
      for_each = var.fetch_git_submodules ? [""] : []
      content {
        fetch_submodules = true
      }
    }
  }

  dynamic "secondary_sources" {
    for_each = var.secondary_sources
    content {
      git_clone_depth     = secondary_source.value.git_clone_depth
      location            = secondary_source.value.location
      source_identifier   = secondary_source.value.source_identifier
      type                = secondary_source.value.type
      insecure_ssl        = secondary_source.value.insecure_ssl
      report_build_status = secondary_source.value.report_build_status

      git_submodules_config {
        fetch_submodules = secondary_source.value.fetch_submodules
      }
    }
  }

  dynamic "logs_config" {
    for_each = length(var.logs_config) > 0 ? [""] : []
    content {
      dynamic "cloudwatch_logs" {
        for_each = contains(keys(var.logs_config), "cloudwatch_logs") ? { key = var.logs_config["cloudwatch_logs"] } : {}
        content {
          status      = lookup(cloudwatch_logs.value, "status", null)
          group_name  = lookup(cloudwatch_logs.value, "group_name", null)
          stream_name = lookup(cloudwatch_logs.value, "stream_name", null)
        }
      }

      dynamic "s3_logs" {
        for_each = contains(keys(var.logs_config), "s3_logs") ? { key = var.logs_config["s3_logs"] } : {}
        content {
          status              = lookup(s3_logs.value, "status", null)
          location            = lookup(s3_logs.value, "location", null)
          encryption_disabled = lookup(s3_logs.value, "encryption_disabled", null)
        }
      }
    }
  }
}
