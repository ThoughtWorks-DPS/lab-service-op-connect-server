variable "aws_region" {}
variable "aws_account_id" {}
variable "aws_assume_role" {}

variable "platform_vpc_name" {}

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
