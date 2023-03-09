resource "aws_lb_target_group" "burining-tg" {
  name = "burining-instg-${var.enviroment}-web-apne2"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.burining-vpc.id
}

resource "aws_lb" "burining-alb" {
  name = "burining-alb-${var.enviroment}-web-apne2"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.burining-albsg.id ]
  subnets = [ for sub in aws_subnet.burining-sub : sub.id ]

  tags = {
    Name = "burining-alb-${var.enviroment}-web-apne2"
  }
}

resource "aws_lb_listener" "burining-alb-listener" {
  load_balancer_arn = aws_lb.burining-alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn = aws_acm_certificate.burining-acm.arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "I'm a teapot"
      status_code = "418"
    }
  }
}

resource "aws_lb_listener_rule" "burining-alb-listener-role" {
  listener_arn = aws_lb_listener.burining-alb-listener.arn
  priority = 10
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.burining-tg.arn
  }

  condition {
    host_header {
      values = [ "${var.domain_name}" ]
    }
  }
}

resource "aws_lb_listener" "burining-alb-listener-http" {
  load_balancer_arn = aws_lb.burining-alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Here!"
      status_code = "403"
    }
  }
}

resource "aws_lb_listener_rule" "burining-alb-listener-role-http" {
  listener_arn = aws_lb_listener.burining-alb-listener-http.arn
  priority = 10
  action {
    type = "redirect"
    
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [ "${var.domain_name}" ]
    }
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.burining-route53.zone_id
  name = "${var.domain_name}"
  type = "A"

  alias {
    name = aws_lb.burining-alb.dns_name
    zone_id = aws_lb.burining-alb.zone_id
    evaluate_target_health = true
  }
}