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

variable "environment_name" {
    type = string
    description = "The name of the EB environment"
}