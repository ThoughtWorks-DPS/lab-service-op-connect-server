resource "aws_cloudwatch_log_group" "op_connect" {
  name = "/ecs/${var.ecs-cluster-name}"
}
