provider "aws" {
    region = "${var.region}"
}

resource "aws_key_pair" "deployer" {
    key_name = "es-cluster-deployer-key"
    public_key = "${file("../keys/private.pem.pub")}"
}

module "eventstore_cluster" {
    source = "./eventstore"

    cluster_name = "${var.cluster_name}"
    number_of_instances = "${var.number_of_instances}"

    region = "${var.region}"
    vpc_id = "${var.vpc_id}"
    subnets = "${var.private_subnets}"
    availability_zones = "${var.availability_zones}"

    ami = "${var.node_ami}"
    instance_type = "${var.node_instance_type}"
    key_name = "${aws_key_pair.deployer.key_name}"
    ingress_cidr_blocks = "0.0.0.0/0"

    backup_bucket_name = "${var.backup_bucket_name}"

    elb_name = "${var.elb_name}"
    elb_sg_id = "${var.elb_sg_id}"
}
