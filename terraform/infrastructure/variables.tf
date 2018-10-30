variable "region" {}

variable "cidr" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "availability_zones" {}

variable "nat_ami" {}
variable "openvpn_ami" {
    default = "ami-44aaf953"
}