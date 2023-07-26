source "amazon-ebs" "ubuntu" {
  ami_name      = "/jenkins/images/${var.ami_name}-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  # vpc_id = var.aws_vpc_id
  # subnet_id = var.aws_subnet_id
  ssh_username = var.ssh_username

  vpc_filter {
    filters = {
      "tag:Name": var.aws_vpc_name,
      "isDefault": "false"
    }
  }

  subnet_filter {
    filters = {
      "tag:Tier": var.aws_subnet_tier
    }
    most_free = true
    random = false
  }

  tags = {
    Name = "jenkins"
    create_at = local.timestamp
    region = var.aws_region
  }

  skip_create_ami = true

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/**ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = [var.base_ami_owner]
  }

}

build {
  name    = "jenkins-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND='noninteractive'"]
    script       = "./jenkins-image-setup.sh"
  }

  provisioner "ansible-local" {
    playbook_file =  "./jenkins-playbook.yaml"
  }

}

variables {
  aws_vpc_name = "dev-vpc"
  aws_subnet_tier  = "public"
  aws_region     = "us-east-1"
  aws_access_key = env("AWS_ACCESS_KEY_ID")
  aws_secret_key = env("AWS_SECRET_ACCESS_KEY")
  ami_name       = "jenkins-server"
  ssh_username   = "ubuntu"
  instance_type  = "t2.micro"
  aws_ami_owner = "099720109477"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}