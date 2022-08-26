output "load_balancer_ip" {
  value = aws_lb.gtd-alb.dns_name
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# output "container_definition" {
#   value = local.output_container_def
# #   sensitive = false
# }