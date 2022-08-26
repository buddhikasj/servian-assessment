output "load_balancer_FQDN" {
  value = aws_lb.gtd-alb.dns_name
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
