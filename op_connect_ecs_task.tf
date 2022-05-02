# connect-api deployment
resource "aws_ecs_task_definition" "op_connect_api" {
  family                   = "op-connect"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.op_connect_api.rendered

  volume {
    name = "op-connect-storage"
  }
}

data "template_file" "op_connect_api" {
  template = file("task-definitions/connect_api.json.tpl")

  vars = {
    connect_api_version        = var.connect_api_version
    connect_api_cpu            = var.connect_api_cpu
    connect_api_ram            = var.connect_api_ram
    aws_region                 = var.aws_region
    aws_account_id             = var.aws_account_id
  }
}

resource "aws_ecs_task_definition" "op_connect_sync" {
  family                   = "op-connect"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.op_connect_sync.rendered

  volume {
    name = "op-connect-storage"
  }
}

data "template_file" "op_connect_sync" {
  template = file("task-definitions/connect_sync.json.tpl")

  vars = {
    connect_sync_version       = var.connect_sync_version
    connect_sync_cpu           = var.connect_sync_cpu
    connect_sync_ram           = var.connect_sync_ram
    aws_region                 = var.aws_region
    aws_account_id             = var.aws_account_id
  }
}

resource "aws_ecs_service" "op_connect_api_service" {
  name            = "op-connect-api"
  cluster         = module.ecs.ecs_cluster_id

  task_definition = aws_ecs_task_definition.op_connect_api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [module.op_connect_sg.security_group_id]
    subnets          = data.aws_subnets.public.ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "op-connect-api"
    container_port   = 8080
  }

  deployment_circuit_breaker {
    enable = true
    rollback = true
  }

  tags = {
    pipeline = "lab-service-op-connect-server"
  }
  
  depends_on = [module.alb, aws_iam_role_policy_attachment.ecs_task_execution_role_attachment]
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "LabOPConnectTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:op-connect-credentials-file"
        }
    ]
}
EOF
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  version = "2012-10-17"
  statement {
    sid = ""
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Traffic to the ECS cluster should only come from the ALB
module "op_connect_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "task-ssg"
  vpc_id      = data.aws_vpc.platform_vpc.id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.connect_api_port
      to_port     = var.connect_api_port
      protocol    = "tcp"
      cidr_blocks = join(",", local.public_cidrs)
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

resource "aws_cloudwatch_log_group" "op_connect" {
  name = "/ecs/op-connect"
}

# op credential file
resource "aws_secretsmanager_secret" "op_connect_credentials_file" {
  name = "op-connect-credentials-file"
}

resource "aws_secretsmanager_secret_version" "op_connect_credentials_file" {
  secret_id     = aws_secretsmanager_secret.op_connect_credentials_file.id
  secret_string = var.op_credentials_file_base64
}