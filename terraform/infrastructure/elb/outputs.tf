output "eventstore_elb_sg" {
    value = "${aws_security_group.eventstore_elb_sg.id}"
}

output "eventstore_elb_name" {
    value = "${aws_elb.eventstore_elb.name}"
}

output "eventstore_elb_address" {
    value = "${aws_elb.eventstore_elb.dns_name}"
}