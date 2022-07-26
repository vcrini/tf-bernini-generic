
variable "alarm_arn" {
  type        = string
  description = "SNS topic to alert when balancer fails"
}
variable "default_cname" {
  type        = string
  description = "cname to use if not specified insied target_groups"
}

variable "lb_name" {
  description = "balancer name"
  default     = null
  type        = string
}
variable "nlb_name" {
  default     = null
  type        = string
  description = "name of LB"
}

variable "listener" {
  default     = null
  description = "map representing listener configuration"
  type        = map(any)
}
variable "ssl_certificate_arn_name" {
  default     = ""
  description = "ssl certificate used by  listener if HTTPS"
  type        = string
}
variable "target_group" {
  default     = {}
  description = "map representing target group configuration"
  type        = map(any)
}
variable "vpc_id" {
  description = "id representing AWS Virtual Private Cloud"
  type        = string
}
locals {
  ssl_certificate_arn = "arn:aws:acm:${local.region}:${local.account_id}:${var.ssl_certificate_arn_name}"
}
