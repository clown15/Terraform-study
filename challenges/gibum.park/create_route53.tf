resource "aws_route53_zone" "burining-route53" {
  name = "${var.domain_name}"
}

resource "aws_acm_certificate" "burining-acm" {
  domain_name = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "burining-acm"
  }
}

resource "aws_route53_record" "burining-record" {
  for_each = {
    for dvo in aws_acm_certificate.burining-acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.burining-route53.id
}

resource "aws_acm_certificate_validation" "burining-acm-validate" {
  certificate_arn         = aws_acm_certificate.burining-acm.arn
  validation_record_fqdns = [for record in aws_route53_record.burining-record : record.fqdn]
}