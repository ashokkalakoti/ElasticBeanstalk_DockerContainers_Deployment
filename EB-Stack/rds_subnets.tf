
resource "aws_subnet" "private_subnet_1a" {
  vpc_id     = "${data.aws_vpc.main.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.availability_zone_1a}"

  tags = {
    Name = "${var.project_name}-RDS_Subnet_1a"
    Project = "${var.project_name}"
  }
}



resource "aws_subnet" "private_subnet_1b" {
  vpc_id     = "${data.aws_vpc.main.id}"
  cidr_block = "10.0.200.0/24"
  availability_zone = "${var.availability_zone_1b}"

  tags = {
    Name = "${var.project_name}-RDS_Subnet_1b"
    Project = "${var.project_name}"
  }
}