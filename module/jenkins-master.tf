# VPC of the subnets
data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
    Environment = var.environment
  }
}

# Subnets of the jenkins instances
data "aws_subnets" "jenkins" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Zone = "public"
  }
}

# Find an official Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical official
}

resource "aws_elb" "jenkins" {
  name_prefix   = "${var.service_name}-"
  security_groups             = [aws_security_group.http.id, aws_security_group.ssh.id]
  subnets                     = data.aws_subnets.jenkins.ids
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/login"
    interval            = 30
  }

   listener {
     instance_port     = 22
     instance_protocol = "TCP"
     lb_port           = 22
     lb_protocol       = "TCP"
   }

  tags = {
    Name               = "${var.service_name}-${var.environment}"
  }
}

data "template_file" "jenkins" {
  template = file("${path.module}/file/install.sh")
}

resource "aws_launch_configuration" "jenkins" {
  name_prefix   = "${var.service_name}-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.http.id, aws_security_group.ssh.id]
  key_name = var.key_name

  user_data              = data.template_file.jenkins.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jenkins" {
  name_prefix   = "${var.service_name}-"
  launch_configuration      = aws_launch_configuration.jenkins.id
  min_size                  = 1
  max_size                  = length(data.aws_subnets.jenkins.ids)
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.jenkins.name]
  termination_policies      = ["OldestLaunchConfiguration"]
  vpc_zone_identifier       = data.aws_subnets.jenkins.ids
  wait_for_capacity_timeout = "20m"

  lifecycle {
    create_before_destroy = true
  }
}