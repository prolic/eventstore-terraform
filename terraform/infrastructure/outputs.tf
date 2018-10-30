output "vpc_id" {
    value = "${module.eventstore_vpc.vpc_id}"
}

output "private_subnets" {
    value = "${module.eventstore_vpc.private_subnets}"
}

output "public_subnets" {
    value = "${module.eventstore_vpc.public_subnets}"
}

output "elb_name" {
    value = "${module.eventstore_elb.eventstore_elb_name}"
}

output "elb_sg_id" {
    value = "${module.eventstore_elb.eventstore_elb_sg}"
}

output "elb_address" {
    value = "${module.eventstore_elb.eventstore_elb_address}"
}

output "vpn_setup_command" {
    value = "${module.eventstore_vpn.vpn_setup_command}"
}
output "vpn_web_console" {
  value = "${module.eventstore_vpn.vpn_web_console}"
}