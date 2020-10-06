output "redis_server" {
    value = aws_elastic_beanstalk_environment.prodenv
    description = "Redis server contents"
}
