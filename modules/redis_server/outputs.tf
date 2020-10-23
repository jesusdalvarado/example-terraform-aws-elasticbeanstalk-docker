output "redis_server" {
    value = aws_elastic_beanstalk_environment.prodenv
    description = "Redis server contents"
}

output "ec2_redis_instance" {
    value = data.aws_instance.ec2
    description = "EC2 instance data"
}
