resource "aws_ec2_transit_gateway" "tgw" {
  description = "tgw for demo centralized egress"
  tags = {
    Name = "my-${var.environment}-tgw"
  }
}

resource "aws_ec2_transit_gateway_route_table" "tgw_rt" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name = "my-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_egress" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  subnet_ids = [for subnet in aws_subnet.public_egress : subnet.id]
  vpc_id     = aws_vpc.vpc_egress.id

  tags = {
    Name = "vpc-egress-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_spoke01" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  subnet_ids = [for subnet in aws_subnet.spoke01_subnets : subnet.id]
  vpc_id     = aws_vpc.vpc_spoke01.id

  tags = {
    Name = "vpc-spoke01-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_spoke02" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  subnet_ids = [for subnet in aws_subnet.spoke02_subnets : subnet.id]
  vpc_id     = aws_vpc.vpc_spoke02.id

  tags = {
    Name = "vpc-spoke02-attachment"
  }
}