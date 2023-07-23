locals {
  tier = {
    public      = "public"
    private     = "private"
    eks_cluster = "eks"
    dmz         = "dmz"
    dba         = "dba"
  }
  vpc_id = "vpc-id"
  jenkins_home = "/var/lib/jenkins"
}