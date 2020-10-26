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

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Redis"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

module "my_redis_server" {
  # Passing values of the variables into the module
  source                   = "./modules/redis_server"
  # docker_image             = "ghcr.io/jesusdalvarado/redis-jesus:latest"
  service_name             = "redis_server"
  service_description      = "Redis DB"
  aws_iam_instance_profile = aws_iam_instance_profile.test_profile.name
  security_group           = aws_security_group.allow_tls.name
  environment_name         = "production"
}

module "my_flask_webserver" {
  source                   = "./modules/webserver"
  service_name             = "flask_web_server"
  service_description      = "Simple web server using Flask"
  aws_iam_instance_profile = aws_iam_instance_profile.test_profile.name
  security_group           = aws_security_group.allow_tls.name
  redis_url                = module.my_redis_server.ec2_redis_instance.public_ip
}

// This is just an example output, reading from the child module. When running terraform apply this output will be printed, it is a way to inspect the values in the console
output "webserver_instance_data" {
  value = module.my_flask_webserver.webserver
}

output "redis_instance_data" {
  value = module.my_redis_server.redis_server
}

output "webserver_url" {
  value = module.my_flask_webserver.webserver.cname
}

output "ec2_redis_instance" {
  value = module.my_redis_server.ec2_redis_instance
}

output "redis_url" {
  value = module.my_redis_server.ec2_redis_instance.public_ip
}
