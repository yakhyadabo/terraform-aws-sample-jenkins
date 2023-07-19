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
  for_each              = var.ports

  load_balancer_arn = aws_lb.jenkins.arn

  protocol          = "TCP" #(TLS)
  port              = each.value # try 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins[each.key].arn
  }
}

resource "aws_lb_target_group" "jenkins" {
  for_each = var.ports

  port        = each.value
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
  max_size                  = length(data.aws_subnets.private.ids)
  desired_capacity          = length(data.aws_subnets.private.ids)
  health_check_type         = "ELB"
  termination_policies      = ["OldestLaunchConfiguration"]
  vpc_zone_identifier       = data.aws_subnets.public.ids
  wait_for_capacity_timeout = "20m"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "target" {
  for_each = var.ports
  autoscaling_group_name = aws_autoscaling_group.jenkins.id
  lb_target_group_arn   = aws_lb_target_group.jenkins[each.key].arn
}