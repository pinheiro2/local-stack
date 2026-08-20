# 1. Trust Policy: WHO can assume this identity?
data "aws_iam_policy_document" "app_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 2. The IAM Role
resource "aws_iam_role" "app_role" {
  name               = "${var.environment}-app-role"
  assume_role_policy = data.aws_iam_policy_document.app_trust_policy.json
}

# 3. Permission Policy: WHAT can this identity do?
data "aws_iam_policy_document" "app_permissions" {
  # Least Privilege: Only allow reading secrets specifically tagged for this app
  statement {
    sid       = "AllowSecretsRead"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    # We restrict this to secrets starting with our environment name in our region
    resources = ["arn:aws:secretsmanager:${var.aws_region}:000000000000:secret:${var.environment}-*"]
  }

  # Least Privilege: Only allow specific S3 actions to a specific bucket path
  statement {
    sid       = "AllowS3AppStorage"
    effect    = "Allow"
    actions   = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = ["arn:aws:s3:::${var.environment}-app-data/*"]
  }
}

# 4. Attach the permissions to the role
resource "aws_iam_policy" "app_policy" {
  name   = "${var.environment}-app-policy"
  policy = data.aws_iam_policy_document.app_permissions.json
}

resource "aws_iam_role_policy_attachment" "app_role_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}