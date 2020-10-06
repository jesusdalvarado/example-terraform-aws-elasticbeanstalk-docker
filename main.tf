terraform {
  backend "s3" {
    bucket          = "mybucket-remote-terraform-state"
    key             = "terraform.tfstate"
    encrypt         = true
    dynamodb_table  = "myapp-terraform-state-locks"
    region          = "us-west-2"
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

// Creating iam_policy to provide permissions
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

module "my_flask_webserver" {
  # Passing values of the variables into the module
  source                   = "./modules/webserver"
  docker_image             = "ghcr.io/jesusdalvarado/jesus-image:latest"
  service_name             = "flask_web_server"
  service_description      = "Simple web server using Flask"
  aws_iam_instance_profile = aws_iam_instance_profile.test_profile.name
}

// This is just an example output, reading from the child module. When running terraform apply this output will be printed, it is a way to inspect the values in the console
 output "instance_data" {
   value = module.my_flask_webserver.webserver
 }