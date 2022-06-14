resource "aws_ecs_task_definition" "op_connect" {
  family                   = "op-connect"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.connect_cpu
  memory                   = var.connect_ram
  container_definitions    = data.template_file.op_connect.rendered

  volume {
    name = "connect-data"
  }
}

data "template_file" "op_connect" {
  template = file("task-definitions/op_connect.json.tpl")

  vars = {
    connect_api_version            = var.connect_api_version
    connect_api_port               = var.connect_api_port
    connect_sync_version           = var.connect_sync_version
    connect_credential_secret_name = var.connect_credential_secret_name
    cloud_watch_log_group_name     = var.ecs-cluster-name
    aws_region                     = var.aws_region
    aws_account_id                 = var.aws_account_id
  }
}

resource "aws_ecs_service" "op_connect_api_service" {
  name            = "op-connect-api"
  cluster         = aws_ecs_cluster.ecs.name

  # task_definition = aws_ecs_task_definition.op_connect_api.arn
  task_definition = aws_ecs_task_definition.op_connect.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [module.op_connect_sg.security_group_id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "connect-api"
    container_port   = 8080
  }

  depends_on = [module.alb, aws_iam_role_policy_attachment.ecs_task_execution_role_attachment]
}

# =================================================================================================
# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.vpc_name}LabOPConnectTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "${var.vpc_name}LabOPConnectTaskRolePolicy"

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
            "Resource": "*"
        }
    ]
}
EOF
}

# The above initially was using the following:
# "Resource": "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:${var.connect_credential_secret_name}"
# however, it would fail saying permission denied

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

  name        = "${var.vpc_name}-task-sg"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.connect_api_port
      to_port     = var.connect_api_port
      protocol    = "tcp"
      cidr_blocks = join(",", module.vpc.public_subnets_cidr_blocks)
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

# op credential file secrets manager key creation managed by bash script: scripts/op-connect-credentials.sh
# update op-connect credential file
resource "aws_secretsmanager_secret_version" "op_connect_credentials_file" {
  secret_id     = data.aws_secretsmanager_secret.op_connect_credentials_file.arn
  secret_string = var.op_credentials_file_base64
}