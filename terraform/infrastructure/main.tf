provider "aws" {
    region = "${var.region}"
}

resource "aws_key_pair" "deployer" {
    key_name = "es-infrastructure-deployer-key"
    public_key = "${file("../keys/private.pem.pub")}"
}

module "eventstore_vpc" {
    source = "./vpc"

    name = "eventstore-vpc"

    cidr = "${var.cidr}"
    private_subnets = "${var.private_subnets}"
    public_subnets = "${var.public_subnets}"

    availability_zones = "${var.availability_zones}"
}

module "eventstore_nat" {
    source = "./nat"

    vpc_id = "${module.eventstore_vpc.vpc_id}"
    vpc_name = "${module.eventstore_vpc.name}"
    subnets = "${module.eventstore_vpc.public_subnets}"
    vpc_cidr_block = "${module.eventstore_vpc.cidr_block}"

    ingress_cidr_blocks = "0.0.0.0/0"

    nat_type = "vpc"
    number_of_instances = 1
    ami = "${var.nat_ami}"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.deployer.key_name}"
    availability_zones = "${module.eventstore_vpc.public_availability_zones}"
}

module "eventstore_vpn" {
    source = "./vpn"

    vpc_id = "${module.eventstore_vpc.vpc_id}"
    public_subnets = "${module.eventstore_vpc.public_subnets}"
    ami = "${var.openvpn_ami}" 
    key_name = "${aws_key_pair.deployer.key_name}"
    tag_name = "eventstore_vpn"
}

module "eventstore_elb" {
    source = "./elb"
    subnets = "${module.eventstore_vpc.private_subnets}"
    vpc_id = "${module.eventstore_vpc.vpc_id}"
}