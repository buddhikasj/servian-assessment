# servian-assessment
This repo contains the terraform code to deploy the servian techchallange application to an AWS account.
Architecture of the infrastructure being deployed is indicated in the below diagram.

![Architecture](app_architecture.png)


## Prerequisites

1. Terraform installed on your local device
2. AWS CLI
3. Create an AWS CLI profile with the credentials of the AWS account (by default this is set to "servian-test-account", But you can override this in prod.tfvars file)

## Execute Terrafrom

`terraform apply -var-file="prod.tfvars"`

Once the infrastructure is deployed output will indicate the DNS name (FQDN) you need to connect to

*load_balancer_FQDN = "xxxx.xxx.elb.amazonaws.com"*

You can simply paste this value on your browser and access the site.
