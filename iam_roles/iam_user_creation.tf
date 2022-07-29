# Create IAM User
resource "aws_iam_user" "iam_user" {
  name = var.aws_iam_user

}

# Create Access Key and Secret Key for IAM User
resource "aws_iam_access_key" "iam_user_key_pairs" {
  user = aws_iam_user.iam_user.name
}

# Store Access Key and Secret Key in AWS SSM
resource "aws_ssm_parameter" "iam_user_aws_access_key" {
  name        = "iam-user-accesskey"
  description = "Access key for IAM User"
  type        = "SecureString"
  value       = aws_iam_access_key.iam_user_key_pairs.id

}

resource "aws_ssm_parameter" "iam_user_aws_secret_key" {
  name        = "iam-user-secretkey"
  description = "Secret Key for IAM User"
  type        = "SecureString"
  value       = aws_iam_access_key.iam_user_key_pairs.secret
}
