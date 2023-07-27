variable "region" {
  type = string
  default = "us-east-1"
}

variable "environment" {
  type = string
  description = "Deployment Environment"
}

variable "service_name" {
  type = string
  default = "jenkins"
}

variable "root_domain" {
  type = string
  nullable = false

  description = <<EOT
  Name of the domain

  Example : dev.example.com
  EOT
}

variable "sub_domain" {
  type = string
  nullable = false

  description = <<EOT
  Name of the sub domain

  Example : jenkins
  EOT
}

variable "vpc_name" {
  type = string
  description = "The name of the vpc"
}

variable "key_name" {
  type = string
  description = "Name of the key pair created in AWS"
}

variable "ports" {
  type    = map(number)
  default = {
    http  = 8080
    https = 443
  }
}

variable "efs_ports" {
  type    = map(number)
  default = {
    icmp  = 2049
   # icmp_1 = -1
  }
}