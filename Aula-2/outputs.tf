output "name_prefix" {
  description = "prefixo de nome apos calculo"
  value = local.name_prefix
}

output "alb_dns" {
  value = aws_alb.main.dns_name
}

output "alb_endpoint" {
  value = "http://${aws_alb.main.dns_name}"
}