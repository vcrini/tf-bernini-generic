module "ecr_immutable" {
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
  #source = "/Users/vcrini/Repositories/terraform-modules/ecr"
  source = "git::https://bitbucket.org/valeri0/ecr.git?ref=0.2.0"
  tags   = var.tag
}
module "ecr_mutable" {
  name   = formatlist("%s-%s", local.ecr_repositories, "snapshot")
  policy = <<EOF
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
  source = "git::https://bitbucket.org/valeri0/ecr.git?ref=0.2.0"
  tags   = var.tag
}
module "deploy" {
  # source                  = "/Users/vcrini/Repositories/terraform-modules/deploy_x_application"
  branch_name             = var.branch_name
  buildspec               = local.buildspec
  cluster_name            = var.aws_ecs_cluster
  codepipeline_bucket     = var.codepipeline_bucket
  deploy_environment      = var.deploy_environment
  deployspec              = local.deployspec
  image                   = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  poll_for_source_changes = "false"
  repository_name         = local.repository_name
  role_arn                = local.role_arn
  role_arn_codebuild      = local.role_arn_codebuild
  role_arn_codepipeline   = local.role_arn_codepipeline
  role_arn_source         = local.role_arn_source
  s3_cache                = var.s3_cache
  #source                  = "/Users/vcrini/Repositories/terraform-modules/deploy_x_application"
  source = "git::https://bitbucket.org/valeri0/deploy_x_application?ref=0.8.0"
  tags   = var.tag
}

resource "aws_cloudwatch_log_group" "log" {
  for_each          = toset([module.deploy.cloudwatch_build_log, module.deploy.cloudwatch_deploy_log])
  name              = each.value
  retention_in_days = var.retention_in_days
  tags              = var.tag
}

module "balancer" {
  alarm_arn            = var.alarm_arn
  default_cname        = var.default_cname
  repository_name      = local.repository_name
  deregistration_delay = 120
  listener             = var.listener
  lb_name              = var.lb_name
  nlb_name             = var.nlb_name
  source = "/Users/vcrini/Repositories/terraform-modules//load_balancer"
  #source              = "git::https://bitbucket.org/valeri0/load_balancer.git//?ref=0.6.0"
  ssl_certificate_arn = local.ssl_certificate_arn
  tags                = var.tag
  target_group        = var.target_group
  target_group_prefix = var.target_group_prefix
  vpc_id              = var.vpc_id
}
