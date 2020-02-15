terraform {
  backend "s3" {
    bucket = "terraform-state-management-bucket"
    key    = "Project/EB-Stack/terraform-application.state"
    region = "us-east-1"
    shared_credentials_file = "~/.aws/config"
    profile                 = "anudeep"
  }
}