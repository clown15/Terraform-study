variable "enviroment" {
  type        = string
  default     = "test"
  description = "enviroment"
}

variable "region" {
  type        = string
  default     = "ap-northeast-2"
  description = "region"
}

variable "vpc-cidr" {
    default = "172.16.0.0/16"
}

variable "burining-pub-subs" {
    type = map
    
    default = {
        pub-open2a = {
            availability_zone = "ap-northeast-2a"
            map_public_ip_on_launch = true
            cidr_block = "172.16.1.0/24"
        }
        pub-open2c = {
            availability_zone = "ap-northeast-2c"
            map_public_ip_on_launch = true
            cidr_block = "172.16.2.0/24"
        }
    }
}

variable "burining-web-pri-subs" {
    type = map

    default = {
        web-open2a = {
            availability_zone = "ap-northeast-2a"
            map_public_ip_on_launch = false
            cidr_block = "172.16.3.0/24"
        }
        web-open2c = {
            availability_zone = "ap-northeast-2c"
            map_public_ip_on_launch = false
            cidr_block = "172.16.4.0/24"
        }
    }
}

variable "burining-db-pri-subs" {
    type = map

    default = {
        db-open2a = {
            availability_zone = "ap-northeast-2a"
            map_public_ip_on_launch = false
            cidr_block = "172.16.5.0/24"
        }
        db-open2c = {
            availability_zone = "ap-northeast-2c"
            map_public_ip_on_launch = false
            cidr_block = "172.16.6.0/24"
        }
    }
}

# variable "vpc-endpoints" {
#   type = list(string)
#   default = [ "secretsmanager", "ssm", "ssmmessages", "ec2messages", "ec2" ]
# }

variable "vpc-endpoints" {
  type = map
  default = {
    secretsmanager = {
        service_name = "secretsmanager"
        vpc_endpoint_type = "Interface"
    }
    ssm = {
        service_name = "ssm"
        vpc_endpoint_type = "Interface"
    }
    ssmmessages = {
        service_name = "ssmmessages"
        vpc_endpoint_type = "Interface"
    }
    ec2messages = {
        service_name = "ec2messages"
        vpc_endpoint_type = "Interface"
    }
    ec2 = {
        service_name = "ec2"
        vpc_endpoint_type = "Interface"
    }
  }
}

variable "instance_types" {
  type        = string
  default     = "t3.medium"
  description = "instance_types"
}

variable "domain_name" {
  type        = string
  default     = "clownp.shop"
  description = "domain_name"
}

variable "secrets" {
  type = map
  default = {
    dbname = "burining"
    username = "dbadmin"
    password = "qwert12345!"
  }
}