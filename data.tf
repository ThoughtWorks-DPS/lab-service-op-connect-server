data "aws_vpc" "platform_vpc" {
  tags = {
    cluster = var.platform_vpc_name
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.platform_vpc.id]
  }
  tags = {
    Tier = "public"
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

locals {
  public_cidrs = [for s in data.aws_subnet.public : s.cidr_block]
}