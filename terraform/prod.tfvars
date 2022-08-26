#### override any variables defined default values
#### terraform apply -var-file="prod.tfvars"   
region = "ap-southeast-1"
default_tags = {

     Environment = "Production"
     Owner       = "Buddhika"
     Project     = "Servian-Assessment"
    #  Application = "GTD-App"
 
}