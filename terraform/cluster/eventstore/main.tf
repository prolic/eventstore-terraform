resource "aws_security_group" "eventstore_ops" {
    name = "eventstore-ops-sg"
    description = "Security group for operations concerns on Event Store instances"
    vpc_id = "${var.vpc_id}"

    tags {
        Name = "eventstore-ops-sg"
    }

    # SSH 
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${split(",", var.ingress_cidr_blocks)}"]
    }
    
    # NTP
    egress {
        from_port = 123
        to_port = 123
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # ELB
    ingress {
       from_port = 2113
       to_port   = 2113
       protocol  = "tcp"
       security_groups = ["${var.elb_sg_id}"]
     }
}

resource "aws_security_group" "eventstore_app" {
    name = "eventstore-app-sg"
    description = "Security group for application concerns on Event Store instances"
    vpc_id = "${var.vpc_id}"

    tags {
        Name = "eventstore-sg"
    }
   
    # Clients HTTP (External)
    ingress {
        from_port = 2113
        to_port = 2113
        protocol = "tcp"
        cidr_blocks = ["${split(",", var.ingress_cidr_blocks)}"]
    }
   
    # Clients TCP (External)
    ingress {
        from_port = 1113
        to_port = 1113
        protocol = "tcp"
        cidr_blocks = ["${split(",", var.ingress_cidr_blocks)}"]
    }
    
    # TCP (Internal)
    ingress {
        from_port = 1112
        to_port = 1112
        protocol = "tcp"
        self = true
    }
    
    # TCP (Internal)
    ingress {
        from_port = 1113
        to_port = 1113
        protocol = "tcp"
        self = true
    }
    
    # HTTP (Internal)
    ingress {
        from_port = 2112
        to_port = 2112
        protocol = "tcp"
        self = true
    }
    
    # HTTP (Internal)
    ingress {
        from_port = 2113
        to_port = 2113
        protocol = "tcp"
        self = true
    }
    
    # TCP - All outbound traffic
    egress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_iam_instance_profile" "eventstore" {
    name = "EventStore-Instance"
    
    roles = [
        "${aws_iam_role.backup_bucket.name}",
    ]
}

resource "aws_launch_configuration" "eventstore" {
    image_id = "${var.ami}"
    instance_type = "${var.instance_type}"
    security_groups = ["${aws_security_group.eventstore_ops.id}", "${aws_security_group.eventstore_app.id}"]
    associate_public_ip_address = false
    ebs_optimized = false
    key_name = "${var.key_name}"
    iam_instance_profile = "${aws_iam_instance_profile.eventstore.id}"
}

resource "aws_autoscaling_group" "eventstore" {
    availability_zones = ["${split(",", var.availability_zones)}"]
    name = "eventstore-asg-${var.cluster_name}"
    max_size = "${var.number_of_instances}"
    min_size = "${var.number_of_instances}"
    desired_capacity = "${var.number_of_instances}"
    default_cooldown = 30
    force_delete = true
    launch_configuration = "${aws_launch_configuration.eventstore.id}"
    vpc_zone_identifier = ["${split(",", var.subnets)}"]
    load_balancers = ["${var.elb_name}"]

    tag {
        key = "Name"
        value = "${format("%s-eventstore", var.cluster_name)}"
        propagate_at_launch = true
    }
}
