source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.component}-${local.timestamp}"
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

  run_tags = {
    Name = "packer-${var.component}-builder"
    component = var.component
    base_ami_id = "{{ .SourceAMI }}"
    base_ami_name = "{{ .SourceAMIName }}"
    version = local.timestamp
    region = var.aws_region
  }

  run_volume_tags = {
    Name = "packer-${var.component}-builder"
    component = var.component
    base_ami_id = "{{ .SourceAMI }}"
    base_ami_name = "{{ .SourceAMIName }}"
    version = local.timestamp
    region = var.aws_region
  }

  snapshot_tags = {
    Name = "${var.component}-${local.timestamp}-snapshot"
    component = var.component
    base_ami_id = "{{ .SourceAMI }}"
    base_ami_name = "{{ .SourceAMIName }}"
    version = local.timestamp
    region = var.aws_region
  }

  tags = {
    Name = "${var.component}-${local.timestamp}"
    component = var.component
    base_ami_id = "{{ .SourceAMI }}"
    base_ami_name = "{{ .SourceAMIName }}"
    version = local.timestamp
    region = var.aws_region
  }

  skip_create_ami = var.skip_create_ami

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/**ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = [var.aws_ami_owner]
  }

}

build {
  name    = "packer-jenkins"
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
  aws_ami_owner = "099720109477"
  component       = "ubuntu-jenkins-master-core"
  ssh_username   = "ubuntu"
  instance_type  = "t2.micro"
  skip_create_ami = true
}

locals {
  timestamp = formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())
}