data "aws_vpc" "platform_vpc" {
  tags = {
    cluster = var.platform_vpc_name
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.platform_vpc.id

  tags = {
    Tier = "public"
  }
}