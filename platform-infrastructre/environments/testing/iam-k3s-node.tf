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
}

resource "aws_iam_role_policy" "k3s_node_ecr_pull" {
  name   = "${var.k3s_node_role_name}-ecr-pull"
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
