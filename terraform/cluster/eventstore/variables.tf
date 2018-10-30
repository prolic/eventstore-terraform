variable "cluster_name" {}
variable "number_of_instances" {}

variable "region" {}
variable "vpc_id" {}
variable "subnets" {}
variable "availability_zones" {}

variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "ingress_cidr_blocks" {}

variable "backup_bucket_name" {}

variable "elb_name" {}
variable "elb_sg_id" {}