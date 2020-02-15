variable "project_name" {
  default = "Beanstalk-poc"
}


variable "availability_zone_1a" {
  default = "us-east-1a"
}



variable "availability_zone_1b" {
  default = "us-east-1b"
}


variable "vpc_id" {
  default = "vpc-0f4747cfe0e47afa2"
}

data "aws_vpc" "main" {
  id = "${var.vpc_id}"
}


################ EB Variables ######################
variable "application_name" {
  default = "demo-docker-cicd"
}
variable "application_description" {
  description = "Sample application based on Elastic Beanstalk & Docker"
  default = "test-cicd"
}

variable "application_environment" {
  description = "Deployment stage e.g. 'staging', 'production', 'test', 'integration'"
  default = "test"
}