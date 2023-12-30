############################ vpc egress section ############################
resource "aws_default_route_table" "vpc_egress_default_rt" {
  default_route_table_id = aws_vpc.vpc_egress.default_route_table_id
  tags = {
    Name = "vpc-egress-default-rt"
  }
}

resource "aws_route_table" "public_egress_rt" {
  vpc_id = aws_vpc.vpc_egress.id
  tags = {
    Name = "public-egress-rt"
  }
}

resource "aws_route_table" "private_egress_rt1" {
  vpc_id = aws_vpc.vpc_egress.id
  tags = {
    Name = "private-egress-rt1"
  }
}

resource "aws_route_table" "private_egress_rt2" {
  vpc_id = aws_vpc.vpc_egress.id
  tags = {
    Name = "private-egress-rt2"
  }
}

resource "aws_route_table_association" "pub_egress_association" {
  count          = length(aws_subnet.public_egress)
  subnet_id      = aws_subnet.public_egress[count.index].id
  route_table_id = aws_route_table.public_egress_rt.id
}

resource "aws_route_table_association" "prv_egress_association1" {
  subnet_id      = aws_subnet.private_egress[0].id
  route_table_id = aws_route_table.private_egress_rt1.id
}

resource "aws_route_table_association" "prv_egress_association2" {
  subnet_id      = aws_subnet.private_egress[1].id
  route_table_id = aws_route_table.private_egress_rt2.id
}

############################ vpc spoke01 section ############################
resource "aws_default_route_table" "vpc_spoke01_default_rt" {
  default_route_table_id = aws_vpc.vpc_spoke01.default_route_table_id
  tags = {
    Name = "vpc-spoke01-default-rt"
  }
}

resource "aws_route_table" "spoke01_rt" {
  vpc_id = aws_vpc.vpc_spoke01.id

  tags = {
    Name = "spoke01-rt"
  }
}

resource "aws_route_table_association" "spoke01_association" {
  count          = length(aws_subnet.spoke01_subnets)
  subnet_id      = aws_subnet.spoke01_subnets[count.index].id
  route_table_id = aws_route_table.spoke01_rt.id
}

############################ vpc spoke02 section ############################
resource "aws_default_route_table" "vpc_spoke02_default_rt" {
  default_route_table_id = aws_vpc.vpc_spoke02.default_route_table_id
  tags = {
    Name = "vpc-spoke02-default-rt"
  }
}

resource "aws_route_table" "spoke02_rt" {
  vpc_id = aws_vpc.vpc_spoke02.id
  tags = {
    Name = "spoke02-rt"
  }
}

resource "aws_route_table_association" "spoke02_association" {
  count          = length(aws_subnet.spoke02_subnets)
  subnet_id      = aws_subnet.spoke02_subnets[count.index].id
  route_table_id = aws_route_table.spoke02_rt.id
}

############################ routing section ############################
resource "aws_route" "public_egress" {
  depends_on             = [aws_internet_gateway.igw]
  route_table_id         = aws_route_table.public_egress_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_egress1" {
  depends_on = [
    aws_nat_gateway.nat_gw
  ]
  route_table_id         = aws_route_table.private_egress_rt1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id
}

resource "aws_route" "private_egress2" {
  depends_on = [
    aws_nat_gateway.nat_gw
  ]
  route_table_id         = aws_route_table.private_egress_rt2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[1].id
}

resource "aws_route" "spoke01_to_egress" {
  depends_on = [
    aws_route_table.spoke01_rt,
    aws_ec2_transit_gateway_vpc_attachment.vpc_spoke01
  ]
  route_table_id         = aws_route_table.spoke01_rt.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "egress_prv1_to_spoke01" {
  depends_on = [
    aws_route_table.private_egress_rt1,
    aws_ec2_transit_gateway_vpc_attachment.vpc_egress
  ]
  route_table_id         = aws_route_table.private_egress_rt1.id
  destination_cidr_block = var.vpc_spoke01_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "egress_prv2_to_spoke01" {
  depends_on = [
    aws_route_table.private_egress_rt2,
    aws_ec2_transit_gateway_vpc_attachment.vpc_egress
  ]
  route_table_id         = aws_route_table.private_egress_rt2.id
  destination_cidr_block = var.vpc_spoke01_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "spoke02_to_egress" {
  depends_on = [
    aws_route_table.spoke02_rt,
    aws_ec2_transit_gateway_vpc_attachment.vpc_spoke02
  ]
  route_table_id         = aws_route_table.spoke01_rt.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "egress_prv1_to_spoke02" {
  depends_on = [
    aws_route_table.private_egress_rt1,
    aws_ec2_transit_gateway_vpc_attachment.vpc_egress
  ]
  route_table_id         = aws_route_table.private_egress_rt1.id
  destination_cidr_block = var.vpc_spoke02_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "egress_prv2_to_spoke02" {
  depends_on = [
    aws_route_table.private_egress_rt2,
    aws_ec2_transit_gateway_vpc_attachment.vpc_egress
  ]
  route_table_id         = aws_route_table.private_egress_rt2.id
  destination_cidr_block = var.vpc_spoke02_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
