output "hostnames" {
  value = aws_elb.jenkins.dns_name
}