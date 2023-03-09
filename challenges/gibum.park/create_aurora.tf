resource "aws_rds_cluster_parameter_group" "burning-param-group" {
  name        = "burning-dparam-${var.enviroment}-mysql-apne2"
  family      = "aurora-mysql5.7"
  description = "RDS default cluster parameter group"
}

resource "aws_rds_cluster" "burning-rds-cluster" {
  cluster_identifier      = "burning-rds-${var.enviroment}-mysql-apne2"
  engine                  = "aurora-mysql"
#   engine_version          = "5.7.mysql_aurora.2.03.2"
#   availability_zones      = ["ap-northeast-2a", "ap-northeast-2c"]
  database_name           = jsondecode(aws_secretsmanager_secret_version.mysecret.secret_string)["dbname"]
  master_username         = jsondecode(aws_secretsmanager_secret_version.mysecret.secret_string)["username"]
  master_password         = jsondecode(aws_secretsmanager_secret_version.mysecret.secret_string)["password"]
#   backup_retention_period = 5
#   preferred_backup_window = "07:00-09:00"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.burning-param-group.id
  skip_final_snapshot = true
  vpc_security_group_ids = [ aws_security_group.burining-rdssg.id ]
  db_subnet_group_name = aws_db_subnet_group.burning_sub_group.name
#   final_snapshot_identifier = 
}

resource "aws_rds_cluster_instance" "burning-rds-inst" {
  count = 2
  identifier = "burning-rdsinst-${var.enviroment}-mysql-apne2-${count.index}"
  cluster_identifier = aws_rds_cluster.burning-rds-cluster.id
  instance_class = "db.t3.medium"
  db_parameter_group_name = aws_db_parameter_group.burning-db-param.id
  engine = aws_rds_cluster.burning-rds-cluster.engine  
#   engine_version = aws_rds_cluster.burning-rds-cluster.engine_version

  tags = {
    Name = "burning-rdsinst-${var.enviroment}-mysql-apne2"
  }
}

resource "aws_db_parameter_group" "burning-db-param" {
  name   = "burning-dparam-${var.enviroment}-mysql-apne2"
  family = "aurora-mysql5.7"
}

resource "aws_db_subnet_group" "burning_sub_group" {
  name = "burning_sub_group"
  subnet_ids = [ for sub in aws_subnet.burining-sub : sub.id ]
}

# data "aws_secretsmanager_secret" "mysecret2" {
#     arn = aws_secretsmanager_secret.mysecret.arn
# }
# resource "aws_secretsmanager_secret_version" "mysecret2" {
#   secret_id = data.aws_secretsmanager_secret.mysecret2.id
#   secret_string = jsonencode({
#     host = aws_rds_cluster.burning-rds-cluster.endpoint
#   })
# }