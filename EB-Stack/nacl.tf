
resource "aws_network_acl" "RDS_NACL" {
  vpc_id = "${data.aws_vpc.main.id}"
  subnet_ids = ["${aws_subnet.private_subnet_1a.id}", "${aws_subnet.private_subnet_1b.id}"]

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.1.0/24"
    from_port  = 3306
    to_port    = 3306
  }

   egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.110.0/24"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.110.0/24"
    from_port  = 3306
    to_port    = 3306
  }

  tags = {
    Name = "RDS_NACL"
    Project = "${var.project_name}"
  }
}

