# VPC of the subnets
data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
    Environment = var.environment
  }
}

# Subnets of the EC2 instances
data "aws_subnets" "service" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  tags = {
    Zone = "public"
  }
}