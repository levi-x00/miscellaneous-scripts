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
  vpc_id = aws_vpc.vpc_egress.id

  tags = {
    Name = "egress-igw"
  }
}

resource "aws_eip" "eips" {
  count  = 2
  domain = "vpc"
  tags = {
    Name = "eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  depends_on = [aws_eip.eips]

  count         = 2
  allocation_id = aws_eip.eips[count.index].id
  subnet_id     = aws_subnet.public_egress[count.index].id

  tags = {
    Name = "nat-gw-${count.index + 1}"
  }
}
