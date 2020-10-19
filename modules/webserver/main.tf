terraform {
    required_version = ">= 0.12"
}

// Create EB app
resource "aws_elastic_beanstalk_application" "webserver" {
  name        = var.service_name
  description = var.service_description
}

// Creating bucket where the docker images will be uploaded to
resource "aws_s3_bucket" "bucket"{
    bucket = "flask-webserver-bucket"
    acl = "public-read"

    tags = {
        Name = "Flask Bucket"
        Environment = "Production"
    }
}

// Create release
// With aws_s3_bucket_object we can upload files to the s3 bucket
resource "aws_s3_bucket_object" "object" {
  bucket    = aws_s3_bucket.bucket.bucket
  key       = "docker-compose.yml"
  source    = "modules/webserver/docker-compose.yml"
}

resource "aws_s3_bucket_object" "env_object" {
  bucket    = aws_s3_bucket.bucket.bucket
  key       = ".env"
  content = jsonencode({
    REDIS_URL=var.redis_url
  })
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "tf-test-version-3"
  application = aws_elastic_beanstalk_application.webserver.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket_object.object.bucket
  key         = aws_s3_bucket_object.object.key
}

resource "aws_elastic_beanstalk_environment" "prodenv" {
  name                = "tf-test-name"
  application         = aws_elastic_beanstalk_application.webserver.name
  solution_stack_name = "64bit Amazon Linux 2 v3.2.0 running Docker"
  version_label       = aws_elastic_beanstalk_application_version.default.name

  setting {
    name        = "IamInstanceProfile"
    namespace   = "aws:autoscaling:launchconfiguration"
    value       = var.aws_iam_instance_profile
  }

  setting {
    name = "SecurityGroups"
    namespace = "aws:autoscaling:launchconfiguration"
    value = var.security_group
  }
}
