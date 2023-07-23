# Jenkins-Master EFS Filesystems
resource "aws_efs_file_system" "jenkins" {
  creation_token = "jenkins-efs"
  # kms_key_id = "${aws_kms_key.jenkins-kms.arn}"
  # encrypted        = var.efs_encrypted
  # performance_mode = var.performance_mode
  tags = {
    Name = "jenkins-efs"
  }
}

resource "aws_efs_mount_target" "jenkins-master" {
  depends_on      = [aws_efs_file_system.jenkins]
  for_each = toset(data.aws_subnets.private.ids)
  file_system_id = aws_efs_file_system.jenkins.id
  subnet_id = each.value
  security_groups =[aws_security_group.efs.id]
}

data "aws_efs_file_system" "jenkins" {
  depends_on = [aws_efs_file_system.jenkins]
  tags = {
    Name = "jenkins-efs"
    Environment = var.environment
  }
}

# --------------------------
# EFS backup
# --------------------------
#resource "aws_efs_backup_policy" "backup_policy" {
#  file_system_id = aws_efs_file_system.jenkins.id
#
#  backup_policy {
#    status = var.backup_policy
#  }
#}