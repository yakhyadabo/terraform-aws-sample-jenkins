# VPC of the subnets
data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
    Environment = var.environment
  }
}

# Subnets where to deploy the jenkins instances
data "aws_subnets" "private" {
  filter {
    name   = local.vpc_id
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Tier = local.tier.private
  }
}

# NLB Subnets
data "aws_subnets" "public" {
  filter {
    name   = local.vpc_id
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Tier = local.tier.public
  }
}