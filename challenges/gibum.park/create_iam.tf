resource "aws_iam_role" "burining-role" {
  name = "burining-role-ec2ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "burining-role-ec2ssm"
  }
}
# aws_iam_role_policy로 생성하면 정책이 생성 되는게 아니라 역할에서 인라인 정책으로 생성되는듯?
resource "aws_iam_role_policy" "custom_role" {
  name = "SecretsManagerRead"
  role = aws_iam_role.burining-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "SecretsManagerRead"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "burining-attachment-ssm" {
  role = aws_iam_role.burining-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
resource "aws_iam_role_policy_attachment" "burining-attachment-s3" {
  role = aws_iam_role.burining-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
# resource "aws_iam_role_policy_attachment" "burining-attachment-secret" {
#   role = aws_iam_role.burining-role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
# }