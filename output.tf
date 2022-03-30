output "role_arn" {
  description = "default role"
  value       = var.role_arn
}
output "role_arn2" {
  description = "secondary role, used for cross account"
  value       = var.role_arn
}
output "codepipeline_bucket" {
  description = "for storing deploy intermediate files"
  value       = var.codepipeline_bucket
}
output "deploy_role" {
  description = "impersonated during deploy"
  value       = var.deploy_role
}
output "kms_arn" {
  description = "allows prod account to start deploy on test"
  value       = var.kms_arn
}
output "role_arn_codepipeline_name" {
  description = "pipeline role"
  value       = var.role_arn_codepipeline_name
}
output "role_arn_task_name" {
  description = "task role"
  value       = var.role_arn_task_name
}
output "s3_cache" {
  description = "s3 bucket for deploy cache"
  value       = var.s3_cache
}
output "role_arn_codebuild" {
  description = "codebuild arn"
  value       = local.role_arn_codebuild
}
