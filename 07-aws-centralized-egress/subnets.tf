############################ vpc egress section ############################
resource "aws_subnet" "public_egress" {
  count                   = length(var.pub_egress_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.vpc_egress.id
  cidr_block              = var.pub_egress_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.application}-pub-egress-subnet-${count.index + 1}",
  }
}

resource "aws_subnet" "private_egress" {
  count                   = length(var.prv_egress_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.vpc_egress.id
  cidr_block              = var.prv_egress_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.application}-prv-egress-subnet-${count.index + 1}",
  }
}

############################ vpc spoke01 section ############################
resource "aws_subnet" "spoke01_subnets" {
  count                   = length(var.spoke01_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.vpc_spoke01.id
  cidr_block              = var.spoke01_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.application}-spoke01-subnet-${count.index + 1}",
  }
}

############################ vpc spoke02 section ############################
resource "aws_subnet" "spoke02_subnets" {
  count                   = length(var.spoke02_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.vpc_spoke02.id
  cidr_block              = var.spoke02_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.application}-spoke02-subnet-${count.index + 1}",
  }
}
