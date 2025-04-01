module "ecr_immutable" {
  force_delete         = var.force_ecr_delete
  image_tag_mutability = "IMMUTABLE"
  name                 = local.ecr_repositories
  policy               = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep no more than 5 images ",
            "selection": {
                "countNumber": 5,
                "countType": "imageCountMoreThan",
                "tagStatus": "any"
            },
            "action": {
                "type": "expire"
            }
        }    
      ]
}
EOF
  #source               = "/Users/vcrini/Repositories/terraform-modules/ecr"
  source = "git::https://bitbucket.org/valeri0/ecr.git?ref=1.1.0"
}
module "ecr_mutable" {
  force_delete = var.force_ecr_delete
  name         = formatlist("%s-%s", local.ecr_repositories, "snapshot")
  policy       = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 3 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }    
      ]
 }
EOF
  source       = "git::https://bitbucket.org/valeri0/ecr.git?ref=1.1.0"
  # source = "/Users/vcrini/Repositories/terraform-modules/ecr"
}
module "deploy" {
  # source                  = "/Users/vcrini/Repositories/terraform-modules/deploy_x_application"
  branch_name             = var.branch_name
  buildspec               = local.buildspec
  codepipeline_bucket     = var.codepipeline_bucket
  deploy_environment      = var.deploy_environment
  deploy_template_name    = var.deploy_template_name
  deployspec              = local.deployspec
  env_in_repository_name  = var.env_in_repository_name
  force_approve           = var.force_approve
  image                   = "aws/codebuild/standard:6.0"
  kms_arn                 = var.kms_arn
  poll_for_source_changes = "false"
  repository_name         = local.repository_name
  role_arn_codebuild      = local.role_arn_codebuild
  role_arn_codepipeline   = local.role_arn_codepipeline
  role_arn_source         = local.role_arn_source
  s3_cache                = var.s3_cache
  source                  = "git::https://bitbucket.org/valeri0/deploy_x_application?ref=1.8.0"
}
#trivy:ignore:AVD-AWS-0017
resource "aws_cloudwatch_log_group" "log" {
  #skip null values
  for_each = {
    for k, v in toset([module.deploy.cloudwatch_build_log, module.deploy.cloudwatch_deploy_log]) :
  k => v if v != null }
  name              = each.value
  retention_in_days = var.retention_in_days
}
# if a lambda then created lambda log group
resource "aws_cloudwatch_log_group" "lambda" {
  count             = var.lambda_log_group == "" ? 0 : 1
  name              = var.lambda_log_group
  retention_in_days = var.retention_in_days
}

module "balancer" {
  # source    = "/Users/vcrini/Repositories/terraform-modules/load_balancer"
  alarm_arn = var.alarm_arn
  # count     = var.lb_name == "" ? 0 : 1
  for_each             = var.lb_name != "" ? toset(["0"]) : toset([])
  default_cname        = var.default_cname
  deploy_environment   = var.deploy_environment
  deregistration_delay = 120
  lb_name              = var.lb_name
  listener             = var.listener
  nlb_name             = var.nlb_name
  prefix               = var.prefix
  repository_name      = local.repository_name
  source               = "git::https://bitbucket.org/valeri0/load_balancer.git//?ref=1.9.0"
  ssl_certificate_arn  = local.ssl_certificate_arn
  ssl_policy           = var.ssl_policy
  target_group         = var.target_group
  vpc_id               = var.vpc_id
}
module "apigateway" {
  providers = {
    aws = aws.no-defauls
  }
  for_each    = var.create_api ? toset(["0"]) : toset([])
  api_gateway = var.api_gateway
  # source      = "/Users/vcrini/Repositories/terraform-modules/tf-apigateway"
  source = "git::https://github.com/vcrini/tf-apigateway//?ref=0.9.0"
}
