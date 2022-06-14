variable "aws_region" {}
variable "aws_account_id" {}
variable "aws_assume_role" {}

variable "vpc_name" {}
variable "vpc_cidr" {}
variable "vpc_azs" {}
variable "vpc_private_subnets" {}
variable "vpc_public_subnets" {}

variable "ecs-cluster-name" {}
variable "capacity_providers" {}
variable "default_capacity_provider" {}

variable "hosted_zone" {}
variable "op_connect_url" {}
variable "alb_name" {}
variable "op_connect_target_group_name" {}
variable "op_credentials_file_base64" {
  sensitive = true
}


variable "connect_api_version" {}
variable "connect_api_port" {}
variable "connect_sync_version" {}
variable "connect_credential_secret_name" {}
variable "connect_cpu" {}
variable "connect_ram" {}
