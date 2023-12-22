resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = var.instance_tenancy

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
