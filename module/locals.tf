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
  jenkins_dns_fqdn = format("%s.%s", var.sub_domain, var.root_domain)
}