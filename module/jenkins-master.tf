resource "random_pet" "jenkins" {
  keepers = {
    environment = var.environment
  }
}

resource "aws_lb" "jenkins" {
  name = join ("-", ["jenkins", random_pet.jenkins.id])
  load_balancer_type = "network"
  subnets            = data.aws_subnets.public.ids

  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "jenkins" {
  load_balancer_arn = aws_lb.jenkins.arn

  protocol          = "TLS"
  port              = var.ports.https

  certificate_arn   = aws_acm_certificate_validation.certificate_validation.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }

}

resource "aws_lb_target_group" "jenkins" {
  port        = var.ports.http
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.main.id
  # target_type = "instance"

  depends_on = [
    aws_lb.jenkins
  ]

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 5
    path                = "/login"
    port                =  var.ports.http
    protocol            = "HTTP"
    interval            = 30
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "jenkins" {
  template = file("${path.module}/file/install.sh")
  vars = {
    MOUNT_TARGET = data.aws_efs_file_system.jenkins.dns_name
    MOUNT_LOCATION = local.jenkins_home
    # REGION = data.aws_region.current.name
    #ALLOCATION_ID = "${aws_eip.jenkins-server-eip.id}"
  }
}

resource "aws_launch_configuration" "jenkins" {
  name_prefix             = join("-", [var.service_name, var.environment])
  image_id                = data.aws_ami.ubuntu.id
  instance_type           = "t2.micro"
  security_groups         = [aws_security_group.http.id, aws_security_group.ssh.id]
  key_name                = var.key_name

  user_data               = data.template_file.jenkins.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jenkins" {
  name_prefix               = join("-", [var.service_name, var.environment])
  launch_configuration      = aws_launch_configuration.jenkins.id
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
#  max_size                  = length(data.aws_subnets.private.ids)
#  desired_capacity          = length(data.aws_subnets.private.ids)
  health_check_type         = "ELB"
  termination_policies      = ["OldestLaunchConfiguration"]
  vpc_zone_identifier       = data.aws_subnets.public.ids
  # vpc_zone_identifier       = [data.aws_subnets.private.ids[0]]
  wait_for_capacity_timeout = "20m"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "target" {
  autoscaling_group_name = aws_autoscaling_group.jenkins.id
  lb_target_group_arn   = aws_lb_target_group.jenkins.arn
}