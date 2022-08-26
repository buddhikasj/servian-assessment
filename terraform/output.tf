####### Output to be used to access the application
output "load_balancer_FQDN" {
  value = aws_lb.gtd-alb.dns_name
}

###### Verify the account and region being deployed to before proceeding to apply
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "region" {
  value = data.aws_region.current.name
}