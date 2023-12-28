output "vpc_id" {
  value = aws_vpc.vpc_egress.id
}

output "vpc_spoke01_id" {
  value = aws_vpc.vpc_spoke01.id
}

output "vpc_spoke02_id" {
  value = aws_vpc.vpc_spoke02.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}
