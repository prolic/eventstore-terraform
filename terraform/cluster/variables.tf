variable "region" {}
variable "cluster_name" {}
variable "number_of_instances" {}

variable "vpc_id" {}
variable "private_subnets" {}
variable "availability_zones" {}

variable "node_ami" {}
variable "node_instance_type" {}

variable "backup_bucket_name" {}

variable "elb_name" {}
variable "elb_sg_id" {}
