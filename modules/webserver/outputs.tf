output "webserver" {
    value = aws_elastic_beanstalk_environment.prodenv
    description = "Webserver contents"
}