module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.18.0"
  create_vpc = true

  name = var.vpc_name
  cidr = var.vpc_cidr
  azs  = var.vpc_azs

  private_subnets     = var.vpc_private_subnets
  private_subnet_suffix = "private-subnet"
  private_subnet_tags = {
    "Tier" = "private"
  }

  public_subnets      = var.vpc_public_subnets
  public_subnet_suffix = "public-subnet"
  public_subnet_tags = {
    "Tier" = "public"
  }

  create_database_subnet_group = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group = false

  map_public_ip_on_launch = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway = true
  single_nat_gateway = true
}
