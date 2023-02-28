variable "region" {
  default = "us-east-1"
}

variable "project" {
  type = object({
    name = string
    team      = string
    contact_email  = string
    environment = string
  })

  description = "Project details"
}

variable "service_name" {
  type = string
  description = "The name of the service deployed with the ELB"
}

variable "key_name" {
  type = string
  description = "Name of the key pair created in AWS"
}