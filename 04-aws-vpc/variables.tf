variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.43.0.0/23"
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
  default = "cicd-application"

}

variable "public_subnet_cidr_blocks" {
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

