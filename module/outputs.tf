output "hostnames" {
  description = "The DNS name of the LB presumably to be used with a friendlier CNAME."
  value       = aws_lb.jenkins.dns_name
}

output "efs" {
  value = aws_efs_file_system.jenkins.dns_name
}