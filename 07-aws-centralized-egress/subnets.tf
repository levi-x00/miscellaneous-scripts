############################ vpc egress section ############################

resource "aws_subnet" "public_egress" {
  count                   = length(var.pub_egress_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.egress.id
  cidr_block              = var.pub_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.application}-public-egress-subnet-${count.index}",
  }
}

resource "aws_subnet" "private_egress" {
  count                   = length(var.prv_egress_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.egress.id
  cidr_block              = var.prv_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.application}-public-egress-subnet-${count.index}",
  }
}
