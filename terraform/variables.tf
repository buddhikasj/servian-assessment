variable "aws_profile" {
  type = string
  default = "servian-test-account"
}
variable "region" {
  type          = string
  description   = "AWS region the instances will be deployed in"
  default       = "ap-southeast-1"
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
  description = "Default Tags for Auto Scaling Group"
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
}

variable "alb_port" {
    type = number
    default = 80
}

variable "web_container_image" {
    type = string
    default = "servian/techchallengeapp:latest"
}

#### generating a random password for the database
#### we can push sensitive value via partial configuration or environmental variables also
resource "random_password" "db_password" {
  length = 10
}

variable "app_count" {
  type = number
  default = 2
}
