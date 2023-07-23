resource "aws_security_group" "http" {
  name        = "allow_http"
  description = "Allow connection between NLB and target"
  vpc_id      = data.aws_vpc.main.id
  tags = {
    Name = "http_sg"
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = var.ports

  security_group_id = aws_security_group.http.id
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.http.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "ssh" {
  name        = "allow_ssh_jenkins"
  description = "Allow SSH traffic into the host"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh_sg"
  }
}

resource "aws_security_group" "icmp" {
  name        = "allow_icmp"
  description = "Allow ping against host for troubleshooting"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "icmp_sg"
  }
}

resource "aws_security_group" "efs" {
  name        = "allow_nfs"
  description = "Allow incoming NFS port"
  vpc_id      = data.aws_vpc.main.id
  tags = {
    Name = "efs_sg"
  }
}

resource "aws_security_group_rule" "efs_ingress" {
  for_each = var.efs_ports

  security_group_id = aws_security_group.efs.id
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "efs_egress" {
  security_group_id = aws_security_group.efs.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}