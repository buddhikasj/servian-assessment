variable "region" {
  type          = string
  description   = "AWS region the instances will be deployed in"
  default       = "us-east-1"
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

variable "vpc_cidr" {
  type          = string
  default       = "10.10.0.0/16"
  description   = "CIDR block of the VPC being created"
}

