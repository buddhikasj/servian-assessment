variable "aws_profile" {
  type = string
  default = "servian-test-account"
  description   = "AWS CLI profile on the local device which will be used deploy resource and execute AWS commands required for deployment"
}

variable "region" {
  type          = string
  description   = "AWS region the instances will be deployed in"
  default       = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "default_tags" {
  default     = {
 
     Environment = "Environment-Not-Set"
     Owner       = "Buddhika"
     Project     = "Servian-Assessment"
 
}
  description = "Default Tags for AWS resources"
  type        = map(string)
}

###### Network Variables
variable "vpc_cidr" {
  type          = string
  default       = "10.10.0.0/16"
  description   = "CIDR block of the VPC being created"
}

variable "public_subnets_cidr" {
	type = list
	default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "web_subnets_cidr" {
	type = list
	default = ["10.10.8.0/24", "10.10.9.0/24"]
}

variable "db_subnets_cidr" {
	type = list
	default = ["10.10.16.0/24", "10.10.17.0/24"]
}

##### APP specific variables

variable "health_check_path" {
    type = string
    default = "/healthcheck/"
}

variable "web_frontend_port" {
    type = number
    default = 3000
    description = "port container is listening on and ECS service"
}

variable "alb_port" {
    type = number
    default = 80
    description = "ALB listener port"
}

variable "web_container_image" {
    type = string
    default = "servian/techchallengeapp:latest"
}

variable "app_count" {
  type = number
  default = 2
}

#### generating a random password for the database, this is by default a sensitive value in TF
#### we can push sensitive value via partial configuration or environmental variables also
resource "random_password" "db_password" {
  length = 10
}

