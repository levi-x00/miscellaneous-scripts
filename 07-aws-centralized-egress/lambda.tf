module "app01" {
  source             = "../03-aws-lambda"
  lambda_name        = "app-01"
  region             = var.region
  profile            = var.profile
  runtime            = "python3.9"
  timeout            = 30
  memory_size        = 128
  subnet_ids         = [for subnet in aws_subnet.spoke01_subnets : subnet.id]
  security_group_ids = [aws_default_security_group.vpc_spoke01_default.id]
}
