# Traffic to the ECS cluster should only come from the ALB
module "task_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "task-ssg"
  vpc_id      = data.aws_vpc.platform_vpc

  ingress_with_cidr_blocks = [
    {
      from_port   = var.connect_server_port
      to_port     = var.connect_server_port
      protocol    = "tcp"
      cidr_blocks = module.alb_lb.id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = var.connect_server_port
      to_port     = var.connect_server_port
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}