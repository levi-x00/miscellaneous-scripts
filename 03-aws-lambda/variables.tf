variable "lambda_name" {
  type    = string
  default = "my-lambda-function"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "zip_file" {
  default = "lambda_function.zip"
}

variable "s3_bucket_lambda" {
  default = ""
}

variable "runtime" {
  default = ""
}

variable "timeout" {
  default = 30
}

variable "memory_size" {
  default = 256
}

variable "handler" {
  default = ""
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}
