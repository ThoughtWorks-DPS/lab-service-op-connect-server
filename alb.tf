module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.10.0"

  name = var.alb_name

  load_balancer_type = "application"

  vpc_id             = data.aws_vpc.platform_vpc.id
  subnets            = data.aws_subnets.public.ids
  security_groups    = [module.alb_sg.security_group_id]

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

  target_groups = [
    {
      name             = var.op_connect_target_group_name
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check     = {
        healthy_threshold   = "3"
        interval            = "30"
        protocol            = "HTTP"
        matcher             = "200"
        timeout             = "3"
        unhealthy_threshold = "2"
        path = "/"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = aws_acm_certificate_validation.op_twdps_digital_certificate.certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "alb-sg"
  vpc_id      = data.aws_vpc.platform_vpc.id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.connect_api_port
      to_port     = var.connect_api_port
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = var.connect_api_port
      to_port     = var.connect_api_port
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# create certificate
resource "aws_acm_certificate" "op_twdps_digital" {
  domain_name       = var.op_connect_url
  validation_method = "DNS"
}

data "aws_route53_zone" "hosted_zone" {
  name = var.hosted_zone
  private_zone = false
}

resource "aws_route53_record" "op_twdps_digital_validation" {
  for_each = {
    for dvo in aws_acm_certificate.op_twdps_digital.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "op_twdps_digital_certificate" {
  certificate_arn         = aws_acm_certificate.op_twdps_digital.arn
  validation_record_fqdns = [for record in aws_route53_record.op_twdps_digital_validation : record.fqdn]
}

resource "aws_route53_record" "op_twdps_digital" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.op_connect_url
  type    = "A"
  ttl     = "300"
  records = [module.alb.lb_dns_name]
}