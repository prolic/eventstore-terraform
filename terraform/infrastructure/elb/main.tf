resource "aws_security_group" "eventstore_elb_sg" {
  name = "eventstore-elb-sg"
  description = "Security group for Event Store ELB"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 2113
    to_port   = 2113
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "EventStore UI Load Balancer"
  }
}

resource "aws_elb" "eventstore_elb" {
  name = "eventstore-elb"
  subnets = ["${split(",", var.subnets)}"]
  security_groups = ["${aws_security_group.eventstore_elb_sg.id}"]
  cross_zone_load_balancing = true
  connection_draining = true
  internal = true

  listener {
    instance_port      = 2113
    instance_protocol  = "tcp"
    lb_port            = 2113
    lb_protocol        = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    target              = "HTTP:2113/stats"
    timeout             = 5
  }
}