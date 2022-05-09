data "aws_vpc" "platform_vpc" {
  tags = {
    cluster = var.platform_vpc_name
  }
}

# data "aws_subnets" "public" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.platform_vpc.id]
#   }
#   tags = {
#     Tier = "public"
#   }
# }

# data "aws_subnet" "public" {
#   for_each = toset(data.aws_subnets.public.ids)
#   id       = each.value
# }

# locals {
#   public_cidrs = [for s in data.aws_subnet.public : s.cidr_block]
# }

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.platform_vpc.id]
  }
  tags = {
    Tier = "private"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

locals {
  private_cidrs = [for s in data.aws_subnet.private : s.cidr_block]
}


data "aws_secretsmanager_secret" "op_connect_credentials_file" {
  name = "${var.connect_credential_secret_name}"
}