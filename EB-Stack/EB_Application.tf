

# S3 Bucket for storiing Elastic Beanstalk task definitions
resource "aws_s3_bucket" "eb_beanstalk_deploys" {
  bucket = "${var.application_name}-deployments"
}

# Elastic Container Repository for Docker images
resource "aws_ecr_repository" "eb_container_repository" {
  name = "${var.application_name}"
}

# Beanstalk instance profile
resource "aws_iam_instance_profile" "eb_beanstalk_ec2" {
  name  = "eb-beanstalk-ec2-user"
  role = "${aws_iam_role.eb_beanstalk_ec2.name}"
}

resource "aws_iam_role" "eb_beanstalk_ec2" {
  name = "eb-beanstalk-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Beanstalk EC2 Policy
# Overriding because by default Beanstalk does not have a permission to Read ECR
resource "aws_iam_role_policy" "eb_beanstalk_ec2_policy" {
  name = "eb_beanstalk_ec2_policy_with_ECR"
  role = "${aws_iam_role.eb_beanstalk_ec2.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:PutMetricData",
        "ds:CreateComputer",
        "ds:DescribeDirectories",
        "ec2:DescribeInstanceStatus",
        "logs:*",
        "ssm:*",
        "ec2messages:*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "ECSAccess",
      "Effect": "Allow",
      "Action": [
        "ecs:Poll",
        "ecs:StartTask",
        "ecs:StopTask",
        "ecs:DiscoverPollEndpoint",
        "ecs:StartTelemetrySession",
        "ecs:RegisterContainerInstance",
        "ecs:DeregisterContainerInstance",
        "ecs:DescribeContainerInstances",
        "ecs:Submit*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Beanstalk Application
resource "aws_elastic_beanstalk_application" "eb_beanstalk_application" {
  name        = "${var.application_name}"
  description = "${var.application_description}"
}

# Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "eb_beanstalk_application_environment" {
  name                = "${var.application_name}-${var.application_environment}"
  application         = "${aws_elastic_beanstalk_application.eb_beanstalk_application.name}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.19.0 running Multi-container Docker 18.09.9-ce (Generic)"
  tier                = "WebServer"
/*
  #### Additional Settings #####

    additional_settings = [
      {
        namespace = "aws:elasticbeanstalk:application:environment"
        name      = "DB_HOST"
        value     = "xxxxxxxxxxxxxx"
      },
      {
        namespace = "aws:elasticbeanstalk:application:environment"
        name      = "DB_USERNAME"
        value     = "yyyyyyyyyyyyy"
      },
      {
        namespace = "aws:elasticbeanstalk:application:environment"
        name      = "DB_PASSWORD"
        value     = "zzzzzzzzzzzzzzzzzzz"
      }
    ]
  */
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${data.aws_vpc.main.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "subnet-0dcb28c58f5fcb0f0,subnet-0b9eaff1365609b6b"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.eb_beanstalk_ec2.name}"
  }

### Optional Settings ###
  setting {
    namespace = "aws:ec2:vpc"
    name = "AssociatePublicIpAddress"
    value = "true"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name = "ELBSubnets"
    value = "subnet-0dcb28c58f5fcb0f0,subnet-0b9eaff1365609b6b"
  }

 setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
 }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t2.micro"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "Availability Zones"
    value = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MinSize"
    value = "2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name = "MaxSize"
    value = "3"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "arn:aws:iam::443777457760:role/aws-elasticbeanstalk-service-role"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "environment"
    value = "testing"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "LOGGING_APPENDER"
    value = "GRAYLOG"
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name = "SystemType"
    value = "enhanced"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateEnabled"
    value = "true"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "RollingUpdateType"
    value = "Health"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "MinInstancesInService"
    value = "2"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name = "MaxBatchSize"
    value = "1"
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name = "CrossZone"
    value = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSizeType"
    value = "Fixed"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "BatchSize"
    value = "1"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name = "DeploymentPolicy"
    value = "Rolling"
  }
  setting {
    namespace = "aws:elb:policies"
    name = "ConnectionDrainingEnabled"
    value = "true"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = "sg-0725c294cd09cb7cb"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "demo-EB"
  }
    
}