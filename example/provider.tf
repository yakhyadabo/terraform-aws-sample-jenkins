provider "aws" {
  region     = var.region

  default_tags {
    tags = {
      Project     = var.project.name
      Team        = var.project.team
      Email       = var.project.contact_email
      Environment = var.project.environment
    }
  }
}
