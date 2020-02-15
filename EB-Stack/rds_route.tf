
resource "aws_route_table" "route_table" {
  vpc_id = "${data.aws_vpc.main.id}"

  tags = {
    Name = "private_RT"
    Project = "${var.project_name}"
  }
}


resource "aws_route_table_association" "route_association_1a" {
  subnet_id      = "${aws_subnet.private_subnet_1a.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table_association" "route_association_1b" {
  subnet_id      = "${aws_subnet.private_subnet_1b.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}
