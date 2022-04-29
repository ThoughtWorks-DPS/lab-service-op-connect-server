module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "6.10.0"

  name = var.target_group_name

  load_balancer_type = "application"

  vpc_id             = data.aws_vpc.platform_vpc
  subnets            = data.aws_subnet_ids.public.ids
  security_groups    = [] # need sg

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

  target_groups = [
    {
      name             = "var.target_group_name"
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
      certificate_arn    = ""  # need cert
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

  tags = {
    pipeline = "lab-service-op-connect-server"
  }
}


module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "alb-ssg"
  vpc_id      = data.aws_vpc.platform_vpc

  ingress_with_cidr_blocks = [
    {
      from_port   = var.connect_server_port
      to_port     = var.connect_server_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  eress_with_cidr_blocks = [
    {
      from_port   = var.connect_server_port
      to_port     = var.connect_server_port
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}






# resource "aws_alb" "main" {
#   name            = "cb-load-balancer"
#   subnets         = aws_subnet.public.*.id
#   security_groups = [aws_security_group.lb.id]
# }

# resource "aws_alb_target_group" "app" {
#   name        = "cb-target-group"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.main.id
#   target_type = "ip"

#   health_check {
#     healthy_threshold   = "3"
#     interval            = "30"
#     protocol            = "HTTP"
#     matcher             = "200"
#     timeout             = "3"
#     path                = var.health_check_path
#     unhealthy_threshold = "2"
#   }
# }

# # Redirect all traffic from the ALB to the target group
# resource "aws_alb_listener" "front_end" {
#   load_balancer_arn = aws_alb.main.id
#   port              = var.app_port
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_alb_target_group.app.id
#     type             = "forward"
#   }
# }
