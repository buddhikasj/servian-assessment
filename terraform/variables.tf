variable "region" {
  type          = string
  description   = "AWS region the instances will be deployed in"
  default       = "us-east-1"
}

variable "azs" {
	type = list
	default = ["us-east-1a", "us-east-1b"]

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
	default = ["10.20.16.0/24", "10.20.17.0/24"]
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

resource "random_password" "db_password" {
  length = 10
}