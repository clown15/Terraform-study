resource "aws_vpc" "burining-vpc" {
    cidr_block = var.vpc-cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"

    tags = {
        Name = "burining-vpc"
    }
}

# 퍼블릭 서브넷
resource "aws_subnet" "burining-sub" {
    for_each = var.burining-pub-subs

    vpc_id = aws_vpc.burining-vpc.id
    availability_zone = each.value.availability_zone
    cidr_block = each.value.cidr_block
    map_public_ip_on_launch = each.value.map_public_ip_on_launch

    tags = {
        Name = "burining-${var.enviroment}-${each.key}"
    }
}

# WEB 프라이빗 서브넷
resource "aws_subnet" "burining-web-pri-sub" {
    for_each = var.burining-web-pri-subs

    vpc_id = aws_vpc.burining-vpc.id
    availability_zone = each.value.availability_zone
    cidr_block = each.value.cidr_block
    map_public_ip_on_launch = each.value.map_public_ip_on_launch

    tags = {
        Name = "burining-${var.enviroment}-${each.key}"
    }
}

# DB 프라이빗 서브넷
resource "aws_subnet" "burining-db-pri-sub" {
    for_each = var.burining-db-pri-subs

    vpc_id = aws_vpc.burining-vpc.id
    availability_zone = each.value.availability_zone
    cidr_block = each.value.cidr_block
    map_public_ip_on_launch = each.value.map_public_ip_on_launch

    tags = {
        Name = "burining-${var.enviroment}-${each.key}"
    }
}

# 인터넷 게이트 웨이 생성
resource "aws_internet_gateway" "burining-igw" {
    vpc_id = aws_vpc.burining-vpc.id

    tags = {
        Name = "burining-igw-${var.enviroment}-vpc-open2"
    }
}

# 퍼블릭 라우팅 테이블 생성
resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.burining-vpc.id

    tags = {
        Name = "burining-rt-${var.enviroment}-pub-open2"
    }
}

# 생성한 퍼블릭 라우팅 테이블에서 경로 설정(IGW)
resource "aws_route" "public_igw_access" {
    route_table_id = aws_route_table.public-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.burining-igw.id
}

# 라우팅 테이블에 서브넷 명시적 연결
resource "aws_route_table_association" "public_subnets" {
    for_each = aws_subnet.burining-sub
    subnet_id = each.value.id
    route_table_id = aws_route_table.public-rt.id
}

# NAT를 위한 EIP 생성
resource "aws_eip" "pri-nat-eip" {
    vpc = true

    lifecycle {
        create_before_destroy = true
    }
}

# NAT생성
resource "aws_nat_gateway" "burining-ntgw" {
    allocation_id = aws_eip.pri-nat-eip.id
    subnet_id = aws_subnet.burining-sub["pub-open2a"].id

    depends_on = [ aws_route.public_igw_access, aws_eip.pri-nat-eip ]
    
    tags = {
        Name = "burining-ntgw-${var.enviroment}-pub-open2"
    }
}

# WEB 프라이빗 서브넷을 위한 라우팅 테이블 생성
# resource "aws_route_table" "web-pri-rt" {
#     vpc_id = aws_vpc.burining-vpc.id

#     tags = {
#         Name = "burining-rt-${var.enviroment}-web-open2"
#     }
# }


# WEB 프라이빗 서브넷을 위한 라우팅 테이블 생성
resource "aws_route_table" "web-pri-rt" {
    vpc_id = aws_vpc.burining-vpc.id

    tags = {
        Name = "burining-rt-${var.enviroment}-web-open2"
    }
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.burining-ntgw.id
    }
}

# WEB 프라이빗 라우팅 테이블에 서브넷 명시적 연결
resource "aws_route_table_association" "web-igw-access" {
    for_each = aws_subnet.burining-web-pri-sub

    subnet_id = each.value.id
    route_table_id = aws_route_table.web-pri-rt.id
}

# DB 프라이빗 서브넷을 위한 라우팅 테이블 생성
resource "aws_route_table" "db-pri-rt" {
    vpc_id = aws_vpc.burining-vpc.id

    tags = {
        Name = "burining-rt-${var.enviroment}-db-open2"
    }
}

# DB 프라이빗 라우팅 테이블에 서브넷 명시적 연결
resource "aws_route_table_association" "db_private_subnets" {
    for_each = aws_subnet.burining-db-pri-sub

    subnet_id = each.value.id
    route_table_id = aws_route_table.db-pri-rt.id
}