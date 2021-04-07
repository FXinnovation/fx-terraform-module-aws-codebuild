data "aws_caller_identity" "current" {
}

#####
# code build Role
data "aws_iam_policy_document" "role" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "permissions" {
  statement {
    sid = ""

    actions = compact(concat([
      "codecommit:GitPull",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecs:RunTask",
      "iam:PassRole",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
    ], var.extra_permissions))

    effect = "Allow"

    resources = [
      "*",
    ]
  }

  dynamic "statement" {
    for_each = var.secondary_artifact_location != null ? [1] : []
    content {
      sid = ""

      actions = [
        "s3:PutObject",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation"
      ]

      effect = "Allow"

      resources = [
        join("", data.aws_s3_bucket.secondary_artifact.*.arn),
        "${join("", data.aws_s3_bucket.secondary_artifact.*.arn)}/*",
      ]
    }
  }
}

data "aws_s3_bucket" "secondary_artifact" {
  count  = (var.secondary_artifact_location != null ? 1 : 0)
  bucket = var.secondary_artifact_location
}

data "aws_iam_policy_document" "vpc_permissions" {
  count = var.vpc_config != {} ? 1 : 0

  statement {
    sid = ""

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = ""

    actions = [
      "ec2:CreateNetworkInterfacePermission"
    ]

    resources = [
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:network-interface/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"
      values = formatlist(
        "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:subnet/%s",
        var.vpc_config.subnets
      )
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values = [
        "codebuild.amazonaws.com"
      ]
    }

  }
}

data "aws_iam_policy_document" "permissions_cache_bucket" {
  count = local.s3_cache_enabled ? 1 : 0
  statement {
    sid = ""

    actions = [
      "s3:*",
    ]

    effect = "Allow"

    resources = [
      join("", aws_s3_bucket.cache_bucket.*.arn),
      "${join("", aws_s3_bucket.cache_bucket.*.arn)}/*",
    ]
  }
}
