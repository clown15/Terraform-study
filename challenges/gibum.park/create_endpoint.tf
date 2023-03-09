resource "aws_vpc_endpoint" "burining-endpoints" {
  vpc_id = aws_vpc.burining-vpc.id
  for_each = var.vpc-endpoints
  service_name = "com.amazonaws.${var.region}.${each.value.service_name}"
  vpc_endpoint_type = "${each.value.vpc_endpoint_type}"

  security_group_ids = [
    aws_security_group.burining-epsg.id,
  ]

  subnet_ids = [ for sub in aws_subnet.burining-sub: sub.id ]
}

resource "aws_vpc_endpoint" "s3-endpoint" {
  vpc_id = aws_vpc.burining-vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
}

resource "aws_vpc_endpoint_route_table_association" "s3-endpoint-association" {
  route_table_id  = aws_route_table.web-pri-rt.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-endpoint.id
}