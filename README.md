<h1>What is this?</h1>

This is an example application built using Terraform to create the resources in AWS. We will use AWS Elastic Beanstalk and Docker to automate deploys.

<h2>Technologies implemented</h2>

- Terraform
- AWS EC2
- AWS Elastic Beanstalk
- Docker
- Redis
- Github actions

<h2>Requirements</h2>

- Make sure you have already installed both Docker Engine and Docker Compose.
- Install aws client and configure it (e.g. using the command aws configure)
- You need to create an S3 bucket called "mybucket-remote-terraform-state" in the region "us-west-2" before running terraform init , this is to use terraform remote state. This bucket has to be created manually in AWS because Terraform can't create it.
- You also need to create a Dynamodb table (the name for primary partition key could be "LockID"). Make sure the region for this resource is also "us-west-2" otherwise you will see the error "Requested resource not found" during terraform init.
- Terraform can read directly from the configured credentials using aws configure, or you can use an .env file like this

        APPLICATION_NAME=app
        AWS_ACCESS_KEY_ID=some_access_key
        AWS_SECRET_ACCESS_KEY=some_secret_key
        AWS_REGION=us-west-2

<h1>Getting Started</h1>

<h2>To create resources in AWS using Terraform</h2>

1. Run terraform init
2. Run terraform plan
3. Run terraform apply
4. After the resoruces are created you can go to the url provided by Elastic Beasntalk for the webserver app  and you should see the message "Hello World! I have been seen {n} times."

<h2>CICD</h2>
To use CICD you need to configure these secrets in GitHub

        AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY
        AWS_REGION
        GH_PAT


After you configure the secret credentials in GitHub, you can deploy the app to EB just by pushing to master branch.