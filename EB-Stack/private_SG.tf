resource "aws_security_group" "Private_SecurityGroup" {
  name        = "Private_SecurityGroup"
  description = "Allow TCP inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = "3306"
    to_port     = "3306"
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["10.0.1.0/24"] # add your IP address here
  }
/*
    egress {
    # TLS (change to whatever ports you need)
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]# add your IP address here
  }
*/
  tags = {
    Name = "Private_SecurityGroup - APP Network"
    Project = "${var.project_name}"
  }
}