data "aws_iam_policy_document" "k3s_node_assume_role" {
  statement {
    sid    = "Ec2AssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k3s_node" {
  name               = var.k3s_node_role_name
  assume_role_policy = data.aws_iam_policy_document.k3s_node_assume_role.json

  tags = merge(local.common_tags, {
    Name = var.k3s_node_role_name
  })
}

data "aws_iam_policy_document" "k3s_node_ecr_pull" {
  statement {
    sid    = "EcrAuthToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EcrPullOnly"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:*:repository/*"]
  }

  statement {
    sid    = "KubecostFederatedStorageBucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    ]
    resources = [aws_s3_bucket.kubecost_federated_storage.arn]
  }

  statement {
    sid    = "KubecostFederatedStorageObjectAccess"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.kubecost_federated_storage.arn}/*"]
  }

  statement {
    sid    = "Route53ChangeRecordsForPlatformZone"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
    ]
    resources = [aws_route53_zone.platform_public.arn]
  }

  statement {
    sid    = "Route53ListZonesForExternalDns"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Route53GetDnsChangeStatus"
    effect = "Allow"
    actions = [
      "route53:GetChange",
    ]
    resources = ["arn:aws:route53:::change/*"]
  }
}

resource "aws_iam_role_policy" "k3s_node_ecr_pull" {
  name   = "${var.k3s_node_role_name}-ecr-s3-route53-access"
  role   = aws_iam_role.k3s_node.id
  policy = data.aws_iam_policy_document.k3s_node_ecr_pull.json
}

resource "aws_iam_instance_profile" "k3s_node" {
  name = var.k3s_node_instance_profile_name
  role = aws_iam_role.k3s_node.name

  tags = merge(local.common_tags, {
    Name = var.k3s_node_instance_profile_name
  })
}
