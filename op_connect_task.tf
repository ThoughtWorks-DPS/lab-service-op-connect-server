# connect-api deployment
resource "aws_ecs_task_definition" "connect_api" {
  family                   = "op-connect-server"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.op_connect_api.rendered

  volume {
    name = "op-connect-api-storage"

    docker_volume_configuration {
      scope         = "task"
      driver        = "local"
    }
  }
}

data "template_file" "op_connect_api" {
  template = file("./task-definitions/connect_api.json.tpl")

  vars = {
    connect_api_version   = var.app_image
    connect_api_cpu       = var.app_port
    connect_api_ram       = var.fargate_cpu
    aws_region            = var.aws_region
  }
}

resource "aws_ecs_task_definition" "connect_sync" {
  family                   = "op-connect-server"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.op_connect_sync.rendered

  volume {
    name = "op-connect-sync-storage"

    docker_volume_configuration {
      scope         = "task"
      driver        = "local"
    }
  }
}

data "template_file" "op_connect_sync" {
  template = file("./task-definitions/connect_sync.json.tpl")

  vars = {
    connect_sync_version   = var.app_image
    connect_sync_cpu       = var.app_port
    connect_sync_ram       = var.fargate_cpu
    aws_region             = var.aws_region
  }
}

resource "aws_ecs_service" "op_connect_api_service" {
  name            = "op-connect-api"
  cluster         = module.ecs.id

  task_definition = aws_ecs_task_definition.connect_api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = data.aws_subnet_ids.public.ids
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
  
  depends_on = [moduile.alb, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
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
