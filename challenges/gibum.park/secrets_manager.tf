resource "aws_s3_bucket" "burning-bucket" {
  bucket = "burning-s3-${var.enviroment}-gibum-apne2"
}

resource "aws_s3_bucket_acl" "burning-bucket-acl" {
  bucket = aws_s3_bucket.burning-bucket.id
  acl = "private"
}

resource "aws_s3_bucket_public_access_block" "burning-public-access" {
  bucket = aws_s3_bucket.burning-bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "burning-bucket-policy" {
  bucket = aws_s3_bucket.burning-bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    sid = "Statement1"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:Get*",
    ]

    resources = [
      "${aws_s3_bucket.burning-bucket.arn}/*",
    ]
  }
}

resource "aws_secretsmanager_secret" "mysecret" {
  name = "myburningsecret"
  recovery_window_in_days = 0
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret_version" "mysecret" {
  secret_id = aws_secretsmanager_secret.mysecret.id
  secret_string = jsonencode({
    dbname = "burining",
    username = "dbadmin",
    password = random_password.password.result,
    bucketname = aws_s3_bucket.burning-bucket.id
    host = data.aws_rds_cluster.myrds.endpoint
  })
}

data "aws_rds_cluster" "myrds" {
    cluster_identifier = "burning-rds-${var.enviroment}-mysql-apne2"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "burning-encryption" {
  bucket = aws_s3_bucket.burning-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}