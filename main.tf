terraform {
  backend "s3" {
    bucket  = "mybucket-remote-terraform-state"
    key     = "terraform.tfstate"
    encrypt = true
    dynamodb_table = "myapp-terraform-state-locks"
    region = "us-west-2"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_elastic_beanstalk_application" "tftest" {
  name          = "my-test"
  description   = "some description"
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "test_role"
  path = "/"

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

resource "aws_elastic_beanstalk_environment" "prodenv" {
  name                = "tf-test-name"
  application         = aws_elastic_beanstalk_application.tftest.name
  solution_stack_name = "64bit Amazon Linux 2 v3.1.0 running Ruby 2.7"

  setting {
    name = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value = aws_iam_instance_profile.test_profile.name
  }
}
