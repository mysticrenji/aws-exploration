
data "aws_iam_policy_document" "s3_role_access_policy" {

  statement {
    sid = "ApplicationObjectAccess"

    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.s3-bucket-lifecycle.arn,
      "${aws_s3_bucket.s3-bucket-lifecycle.arn}/*",
    ]
  }
}

resource "aws_iam_role" "s3_role_assume" {

  name        = "s3-bucket-assume-role"
  description = "Role for s3 bucket"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        "AWS" : aws_iam_user.iam_user.arn
      },
      Condition : {}
    }],
    Version = "2012-10-17"
  })

}

resource "aws_iam_policy" "s3_iam_policy" {
  name   = "s3_iam_policy"
  policy = data.aws_iam_policy_document.s3_role_access_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_role_policy_attachment" {
  role       = aws_iam_role.s3_role_assume.name
  policy_arn = aws_iam_policy.s3_iam_policy.arn
}
