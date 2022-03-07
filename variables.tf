variable "aws_ecs_cluster" {
  description = "cluster name"
  type        = string
}
variable "aws_security_group" {
  description = "one or more security group used by containers"
  type        = string
}
variable "aws_subnet" {
  description = "subnet where containers run"
  type        = string
}
variable "aws_account_id2" {
  default     = "092467779203"
  description = "needed for creating role to create infrastructure for codecommit in prod enviroment"
  type        = string
}

variable "aws_desired_count" {
  default     = 1
  description = "how many tasks run"
  type        = number
}
variable "additional_ecr_repos" {
  default     = []
  description = "used to create ECR infrastructure if there is more than one"
  type        = list(any)
}
variable "force_approve" {
  type        = string
  default     = "false"
  description = "if false than an approve is requested, otherwise there is no approve phase after build and before deploy"
}

variable "role_arn_source_name" {
  default     = "assumecodecommitguccidev"
  description = "used to allow production to trigger in test events"
  type        = string
}
variable "dockerhub_user" {
  description = "used to allow more than 100 pull in 6 hours (should be 200) see https://docs.docker.com/docker-hub/download-rate-limit/"
  type        = string
}
variable "ecs_image_pull_behavior" {
  type        = string
  default     = "always"
  description = "to ensure lastest images is alway pulled"
}
variable "branch_name" {
  description = "branch used from codecommit"
  type        = string
}
variable "codepipeline_bucket" {
  description = "bucketname used from pipeline to pass configurations needed for codebuild"
  type        = string
}
variable "codeartifact_repository" {
  description = "repository name for codeartifact"
  type        = string
}
variable "codeartifact_domain" {
  description = "domain name for codeartifact"
  type        = string
}
variable "codeartifact_account_id" {
  description = "domain name for codeartifact"
  type        = string
}
variable "deploy_environment" {
  description = "test or prod environment"
  type        = string
}
variable "deploy_role" {
  default     = "dpl-admin-role"
  description = "role used to deploy"
}
variable "deployment_max_percent" {
  default     = 100
  description = "all tasks continue to run during deploy"
  type        = number
}
variable "deployment_min_healthy_percent" {
  default     = 0
  description = "to deploy without use more cluster capacity"
  type        = number
}
variable "deploy_versions" {
  default     = true
  description = "enables deploying specific versions through dedicated pipeline"
  type        = string
}
variable "enable_cross_account" {
  description = "flag to install accordingly to environment cross notifies between AWS accounts"
  type        = string
}
variable "image_repo_name" {
  default     = "fdh-sbt"
  description = "name of repository with sbt builder image"
  type        = string
}
variable "kms_arn" {
  default     = "arn:aws:kms:eu-west-1:796341525871:key/e9141a5d-f993-    464d-af9e-82f5272c85f9"
  description = "kms keys used to crypt bucket to enable cross account access for prod -> test"
  type        = string
}
variable "manage_repositories" {
  default     = "false"
  description = "to let this library to manage directly repository creation"
  type        = string
}
variable "nginx" {
  default     = {}
  description = "dictionary environment variable to use as dynamic hostname for homonym component"
  type        = map(any)
}
variable "prefix" {
  description = "prefix name for infrastructure, ex. fdh, dpl, bitots"
  type        = string
}
variable "repository_name" {
  description = "name of the repository inferred by directory name"
  type        = string
}
variable "retention_in_days" {
  default     = 30
  description = "how many days wait before deleting logs"
  type        = number
}
variable "role_arn" {
  description = "assumed to create infrastructure in enviroment where .hcl is ran"
  type        = string
}
variable "role_arn2" {
  default     = "arn:aws:iam::092467779203:role/dpl-admin-role"
  description = "assumed to create infrastructure in prod enviroment where codecommit repositories are expected to be"
  type        = string
}
variable "role_arn_codepipeline_name" {
  description = "role used by codepipeline"
  type        = string
}
variable "role_arn_task_name" {
  default     = "dpl-task-role"
  description = "role used by container"
  type        = string
}
variable "s3_aws_access_key_id" {
  default     = "AKIAQRJF3PUJGXL5OJLD"
  description = "account used to access scala libraries"
  type        = string
}
variable "s3_aws_role_arn" {
  default     = "arn:aws:iam::092467779203:role/FDH-Repository-Role"
  description = "role used to access scala libraries"
  type        = string
}
variable "s3_cache" {
  description = "s3 bucket cache name"
  type        = string
}
variable "sbt_image_version" {
  default     = "0.1"
  description = "sbt version used"
  type        = string
}
variable "sbt_opts" {
  default     = "-XX:+CMSClassUnloadingEnabled -Xmx2G -Xss8M"
  description = "parameters needed to compile without errors"
  type        = string
}
variable "tag" {
  default = {
    Project = "FactoryDataHub"
  }
  description = "tag to be added"
  type        = map(any)
}
variable "tag_alt" {
  default = {
    Project = "FactoryDataHub"
  }
  description = "tag to be added with the alternative account a.k.a prod one"
  type        = map(any)
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  account_id             = data.aws_caller_identity.current.account_id
  proxy_name             = "${local.repository_name}-proxy"
  region                 = data.aws_region.current.name
  repository_name        = var.repository_name
  repository_name_deploy = "${local.repository_name}-deploy"

  role_prefix  = "arn:aws:iam::${local.account_id}:role/"
  role_prefix2 = "arn:aws:iam::${var.aws_account_id2}:role/"
}
locals {
  arn_target       = "arn:aws:events:${local.region}:${local.account_id}:event-bus/default"
  ecr_repositories = compact(concat([local.repository_name], formatlist("%s-%s", local.repository_name, var.additional_ecr_repos)))

  image_repo            = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/"
  key                   = "terraform/tfstate/$(local.repository_name).tfstate"
  role_arn              = "${local.role_prefix}${var.deploy_role}"
  role_arn2             = "${local.role_prefix2}${var.deploy_role}"
  role_arn_target       = "${local.role_prefix}${var.prefix}-start-pipeline-automation"
  role_arn_target2      = "${local.role_prefix2}${var.prefix}-start-pipeline-automation"
  role_arn_task         = "${local.role_prefix}${var.prefix}-${var.deploy_environment}-task"
  role_arn_codebuild    = "${local.role_prefix}${var.prefix}-${var.deploy_environment}-codebuild"
  role_arn_codepipeline = "${local.role_prefix}${var.role_arn_codepipeline_name}"
  role_arn_source       = "${local.role_prefix2}${var.prefix}-prod-${var.role_arn_source_name}"
  buildspec = templatefile("${path.module}/templates/buildspec.tmpl",
    {
      codeartifact_account_id = var.codeartifact_account_id
      codeartifact_repository = var.codeartifact_repository
      codeartifact_domain     = var.codeartifact_domain
      dockerhub_user          = var.dockerhub_user
      environment             = var.deploy_environment
      image_repo              = local.image_repo
      image_repo_name         = var.image_repo_name
      proxy_name              = local.proxy_name
      repository_name         = local.repository_name
      s3_aws_access_key_id    = var.s3_aws_access_key_id
      s3_aws_default_region   = local.region
      s3_aws_role_arn         = var.s3_aws_role_arn
      sbt_image_version       = var.sbt_image_version
      sbt_opts                = var.sbt_opts
    }
  )
  deploy2_name = local.repository_name_deploy
  deployspec = templatefile("${path.module}/templates/deployspec.tmpl",
    {
      aws_container_name             = var.target_group["app"]["container"]
      aws_container_port             = var.target_group["app"]["destination_port"]
      aws_desired_count              = var.aws_desired_count
      aws_ecs_cluster                = var.aws_ecs_cluster
      aws_service_name               = local.repository_name
      aws_security_group             = var.aws_security_group
      aws_stream_prefix              = local.repository_name
      aws_subnet                     = var.aws_subnet
      aws_target_group_arn           = module.balancer.output_lb_target_group["app"].arn
      deployment_max_percent         = var.deployment_max_percent
      deployment_min_healthy_percent = var.deployment_min_healthy_percent
      ecs_image_pull_behavior        = var.ecs_image_pull_behavior
      environment                    = var.deploy_environment
      image_repo                     = local.image_repo
      image_repo_name                = var.image_repo_name
      proxy_name                     = local.proxy_name
      repository_name                = local.repository_name
      sbt_image_version              = var.sbt_image_version
      task_role_arn                  = local.role_arn_task
      ENV                            = var.deploy_environment
      nginx                          = var.nginx

    }
  )
  ecr_repository_list          = [local.repository_name]
  ecr_repository_list_snapshot = [for name in local.ecr_repository_list : "${name}-snapshot"]
}
