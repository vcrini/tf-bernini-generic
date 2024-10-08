provider "aws" {
  assume_role {
    role_arn = var.role_arn
  }
  default_tags { tags = var.tag }
}
provider "aws" {
  alias = "prod"
  assume_role {
    role_arn = var.role_arn2
  }
}
provider "aws" {
  alias = "no-defauls"
  assume_role {
    role_arn = var.role_arn
  }
}

