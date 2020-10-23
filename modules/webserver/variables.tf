variable "service_name" {
    type        = string
    description = "Name of the service"
}

variable "service_description" {
    type        = string
    description = "Description of the service"
}

variable "aws_iam_instance_profile" {
    type        = string
    description = "AWS IAM Instance Profile"
}

variable "security_group" {
    type        = string
    description = "AWS Security Group"
}

variable "redis_url" {
    type        = string
    description = "URL used to connect to the Redis Database"
}