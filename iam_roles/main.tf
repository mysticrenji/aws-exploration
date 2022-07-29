resource "aws_s3_bucket" "s3-bucket-lifecycle" {

  bucket = var.bucket_name

  tags = {
    Enviroment : "Production"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3-bucket-lifecycle.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "versioning_bucket_acl" {
  bucket = aws_s3_bucket.s3-bucket-lifecycle.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {

  bucket = aws_s3_bucket.s3-bucket-lifecycle.bucket

  rule {
    id = "archival"

    filter {
      and {
        prefix = "/"

        tags = {
          rule      = "archival"
          autoclean = "false"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}
