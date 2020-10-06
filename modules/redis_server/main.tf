terraform {
    required_version = ">= 0.12"
}

// Create EB app
resource "aws_elastic_beanstalk_application" "redis_server" {
  name        = var.service_name
  description = var.service_description
}

resource "aws_s3_bucket" "bucket" {
    bucket = "redis-bucket"
    acl = "public-read"

    tags = {
        Name = "Redis Bucket"
        Environment = "Production"
    }
}

// Create release
// With aws_s3_bucket_object we can upload files to the s3 bucket
resource "aws_s3_bucket_object" "object" {
  bucket    = aws_s3_bucket.bucket.bucket
  key       = "Dockerrun.aws.json"
  content   = jsonencode({
    "AWSEBDockerrunVersion": "1",
    "Image": {
      # "Name": "docker.pkg.github.com/jesusdalvarado/example-terraform-aws-elasticbeanstalk-docker/jesus-image:v1" // Using Github Package Registry (requires authentication)
      # "Name": "alvaradojesus/deploying_aws_elastic_beanstalk:v1" // Using docker registry
      # "Name": "ghcr.io/jesusdalvarado/jesus-image:v1" // Using GitHub Container Registry
      "Name": var.docker_image // This reads from ./variables.tf. The values in variables.tf are passed from the root main.tf
    },
    "Ports": [
      {
        "ContainerPort": 6379
      }
    ]
  })
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "tf-test-version-3"
  application = aws_elastic_beanstalk_application.redis_server.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket_object.object.bucket
  key         = aws_s3_bucket_object.object.key
}

resource "aws_elastic_beanstalk_environment" "prodenv" {
  name                = "production"
  application         = aws_elastic_beanstalk_application.redis_server.name
  solution_stack_name = "64bit Amazon Linux 2 v3.1.2 running Docker"
  version_label       = aws_elastic_beanstalk_application_version.default.name

  setting {
    name        = "IamInstanceProfile"
    namespace   = "aws:autoscaling:launchconfiguration"
    value       = var.aws_iam_instance_profile
  }
}
