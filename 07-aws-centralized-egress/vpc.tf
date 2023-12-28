resource "aws_vpc" "vpc_egress" {
  cidr_block       = var.vpc_egress_cidr_block
  instance_tenancy = var.instance_tenancy

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
}

resource "aws_vpc" "vpc_spoke01" {
  cidr_block       = var.vpc_spoke01_cidr_block
  instance_tenancy = var.instance_tenancy

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
}

resource "aws_vpc" "vpc_spoke02" {
  cidr_block       = var.vpc_spoke02_cidr_block
  instance_tenancy = var.instance_tenancy

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
