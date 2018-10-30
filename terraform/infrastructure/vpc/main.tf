resource "aws_vpc" "vpc" {
    cidr_block = "${var.cidr}"

    tags {
        Name = "vpc-${var.name}"
    }
}

resource "aws_subnet" "private" {
    count = "${length(split(",", var.private_subnets))}"

    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${element(split(",", var.private_subnets), count.index)}"
    availability_zone = "${element(split(",", var.availability_zones), count.index)}"
    
    tags {
        Name = "sn-${var.name}-private-${count.index}"
        network = "private"
    }
}

resource "aws_subnet" "public" {
    count = "${length(split(",", var.public_subnets))}"

    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${element(split(",", var.public_subnets), count.index)}"
    availability_zone = "${element(split(",", var.availability_zones), count.index)}"
    map_public_ip_on_launch = true
    
    tags {
        Name = "sn-${var.name}-public-${count.index}"
    }
}

resource "aws_internet_gateway" "vpc" {
    vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "private" {
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "rt-${var.name}-private"
    }
}

resource "aws_route_table_association" "private" {
    count = "${length(split(",", var.private_subnets))}"

    subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.vpc.id}"
    }

    tags {
        Name = "rt-${var.name}-public"
    }
}

resource "aws_route_table_association" "public" {
    count = "${length(split(",", var.public_subnets))}"

    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id = "${aws_route_table.public.id}"
}
