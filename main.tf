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

variable "AWS_REGION" {
  # default = "us-west-2"
  type = string
}

provider "aws" {
  profile = "default"
  region  = var.AWS_REGION
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
            "Effect": "Allow"
        }
    ]
}
EOF
}

// You could also use the arn "arn:aws:iam::aws:policy/AdministratorAccess" rather than creating this custom policy (same effect)
resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
  # policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}



// Create release
// With aws_s3_bucket_object we can upload files to the s3 bucket
resource "aws_s3_bucket_object" "object" {
  bucket = "mybucket-remote-terraform-state"
  key    = "Dockerrun.aws.json"
  content = jsonencode({
    "AWSEBDockerrunVersion": "1",
    "Image": {
      # "Name": "docker.pkg.github.com/jesusdalvarado/example-terraform-aws-elasticbeanstalk-docker/jesus-image:v1" // Using Github Package Registry (requires authentication)
      # "Name": "alvaradojesus/deploying_aws_elastic_beanstalk:v1" // Using docker registry
      "Name": "ghcr.io/jesusdalvarado/jesus-image:v1" // Using GitHub Container Registry
    },
    "Ports": [
      {
        "ContainerPort": 8080
      }
    ]
  })
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "tf-test-version-1"
  application = aws_elastic_beanstalk_application.tftest.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket_object.object.bucket
  key         = aws_s3_bucket_object.object.key
}

resource "aws_elastic_beanstalk_environment" "prodenv" {
  name                = "tf-test-name"
  application         = aws_elastic_beanstalk_application.tftest.name
  solution_stack_name = "64bit Amazon Linux 2 v3.1.2 running Docker"
  version_label       = aws_elastic_beanstalk_application_version.default.name

  setting {
    name = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value = aws_iam_instance_profile.test_profile.name
  }
}