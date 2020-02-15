terraform {
  backend "s3" {
    bucket = "terraform-state-management-bucket"
    key    = "Project/VPC_Infra/terrafprm-vpc.state"
    region = "us-east-1"
    shared_credentials_file = "~/.aws/config"
    profile                 = "anudeep"
  }
}