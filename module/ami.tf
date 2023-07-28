# Find an official Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners           = ["self"]

  filter {
    name   = "tag:component"
    values = ["ubuntu-jenkins-master-core"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

}