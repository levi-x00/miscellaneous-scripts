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
  default = []
}

variable "prv_egress_subnet_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "spoke01_subnet_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "spoke02_subnet_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "availability_zones" {
  type    = list(string)
  default = []
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}
