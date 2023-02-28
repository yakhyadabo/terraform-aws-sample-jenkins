module "jenkins" {
  source               = "../module"
  region               = var.region
  environment          = var.project.environment
  vpc_name             = "${var.project.environment}-vpc"
  service_name         = var.service_name
  key_name             = var.key_name
}