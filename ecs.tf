module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "3.5.0"
  create_ecs = true

  name = var.ecs-cluster-name
  container_insights = true
  capacity_providers = var.capacity_providers

  tags = {
    pipeline = "lab-service-op-connect-server"
  }
}