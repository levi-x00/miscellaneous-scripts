variable "region" {
  type    = string
  default = "us-east-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "vpc_egress_cidr_block" {
  type    = string
  default = "10.43.0.0/24"
}

variable "vpc_spoke01_cidr_block" {
  type    = string
  default = "10.44.0.0/24"
}

variable "vpc_spoke02_cidr_block" {
  type    = string
  default = "10.45.0.0/24"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "application" {
  type    = string
  default = "centralized-egress"

}

variable "pub_egress_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.43.0.0/26", "10.43.0.64/26"]
}

variable "prv_egress_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.43.0.128/26", "10.43.0.192/26"]
}

variable "spoke01_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.44.0.0/25", "10.44.0.128/25"]
}

variable "spoke02_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.45.0.0/25", "10.45.0.128/25"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}
