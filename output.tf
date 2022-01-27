output "role_arn" {
  description = "default role"
  value       = var.role_arn
}
output "role_arn2" {
  description = "secondary role, used for cross account"
  value       = var.role_arn
}
