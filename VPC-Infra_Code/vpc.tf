resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "custom-vpc-Beanstalk"
    Project = "${var.project_name}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.project_name}-IGW"
    Project = "${var.project_name}"
  }
}

resource "aws_subnet" "public_subnet_1a" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.availability_zone_1a}"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.project_name}-PublicSubnet_1a"
    Project = "${var.project_name}"
  }
}



resource "aws_subnet" "public_subnet_1b" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.110.0/24"
  availability_zone = "${var.availability_zone_1b}"
  map_public_ip_on_launch = "true"


  tags = {
    Name = "${var.project_name}-PublicSubnet_1b"
    Project = "${var.project_name}"
  }
}



resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Public_RT"
    Project = "${var.project_name}"
  }
}

resource "aws_route_table_association" "route_association_1a" {
  subnet_id      = "${aws_subnet.public_subnet_1a.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table_association" "route_association_1b" {
  subnet_id      = "${aws_subnet.public_subnet_1b.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}


resource "aws_network_acl" "Public_NACL" {
  vpc_id = "${aws_vpc.main.id}"
  subnet_ids = ["${aws_subnet.public_subnet_1a.id}", "${aws_subnet.public_subnet_1b.id}"]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "Public_NACL"
    Project = "${var.project_name}"
  }
}