resource "aws_security_group" "nat" {
    name = "nat-sg"
    description = "Security group for NAT instances"
    vpc_id = "${var.vpc_id}"

    tags {
        Name = "sg-nat"
    }

    # SSH
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.ingress_cidr_blocks}"]
    }

    # NTP
    ingress {
        from_port = 123
        to_port = 123
        protocol = "udp"
        cidr_blocks = ["${var.vpc_cidr_block}"]
    }

    # ICMP
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc_cidr_block}"]
    }

    # HTTPS
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr_block}"]
    }
    
    # HTTP
    ingress {
        from_port = 80
        to_port = 80 
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr_block}"]
    }
    
    # DNS
    ingress {
        from_port = 53
        to_port = 53 
        protocol = "udp"
        cidr_blocks = ["${var.vpc_cidr_block}"]
    }

    # Outbound SSH to other instances (TODO(jen20): fix this)
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr_block}"]
    }

    # All outbound traffic
    egress {
        from_port = 0
        to_port = 65535
        protocol ="tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_iam_role" "nat" {
    name = "HA-NAT"
    assume_role_policy = "${file("${path.module}/policies/assume-role-policy.json")}"
}

resource "aws_iam_role_policy" "nat" {
    name = "HA-NAT"
    role = "${aws_iam_role.nat.id}"
    policy = "${file("${path.module}/policies/policy-ha-nat.json")}"
}

resource "aws_iam_instance_profile" "nat" {
    name = "HA-NAT"
    roles = ["${aws_iam_role.nat.name}"]
}

resource "aws_launch_configuration" "nat" {
    image_id = "${var.ami}"
    instance_type = "${var.instance_type}"
    security_groups = ["${aws_security_group.nat.id}"]
    associate_public_ip_address = true
    ebs_optimized = false
    key_name = "${var.key_name}"
    iam_instance_profile = "${aws_iam_instance_profile.nat.id}"
    user_data = "${file("${path.module}/scripts/cloudinit-nat-per-${var.nat_type}")}"
}

resource "aws_autoscaling_group" "nat" {
    availability_zones = ["${split(",", var.availability_zones)}"]
    name = "${format("%s-nat", var.vpc_name)}"
    max_size = "${var.number_of_instances}"
    min_size = "${var.number_of_instances}"
    health_check_grace_period = 30
    health_check_type = "EC2"
    desired_capacity = "${var.number_of_instances}"
    default_cooldown = 30
    force_delete = true
    launch_configuration = "${aws_launch_configuration.nat.name}"
    vpc_zone_identifier = ["${split(",", var.subnets)}"]

    tag {
        key = "Name"
        value = "${format("%s-nat", var.vpc_name)}"
        propagate_at_launch = true
    }
}
