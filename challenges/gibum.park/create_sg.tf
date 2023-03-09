resource "aws_security_group" "burining-epsg" {
  vpc_id = aws_vpc.burining-vpc.id
  name = "burining-epsg-${var.enviroment}-comm-open2"

  tags = {
    Name = "burining-epsg-${var.enviroment}-comm-open2"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "${var.vpc-cidr}" ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "${var.vpc-cidr}" ]
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}

resource "aws_security_group" "burining-albsg" {
  vpc_id = aws_vpc.burining-vpc.id
  name = "burining-albsg-${var.enviroment}-web-open2"

  tags = {
    Name = "burining-albsg-${var.enviroment}-web-open2"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}

resource "aws_security_group" "burining-ec2sg" {
  vpc_id = aws_vpc.burining-vpc.id
  name = "burining-ec2sg-${var.enviroment}-web-open2"

  tags = {
    Name = "burining-ec2sg-${var.enviroment}-web-open2"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [ aws_security_group.burining-albsg.id ]
  }

  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
}

resource "aws_security_group" "burining-rdssg" {
  vpc_id = aws_vpc.burining-vpc.id
  name = "burining-rdssg-${var.enviroment}-mysql-open2"

  tags = {
    Name = "burining-rdssg-${var.enviroment}-mysql-open2"
  }

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [ aws_security_group.burining-ec2sg.id ]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    # self를 true로 설정하면 자신의 id가 들어간다
    self = true
  }

  egress {
    from_port = 0
    protocol = "tcp"
    to_port = 0
    self = true
  }
}