# Domain hosted zone
data "aws_route53_zone" "root_domain" {
  name = var.root_domain
  # private_zone = true
}

# Certificate generation and validation:
resource "aws_acm_certificate" "certificate" {
  domain_name = local.jenkins_dns_fqdn
  validation_method = "DNS"
}

resource "aws_route53_record" "certificate_validation" {
  name    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.root_domain.zone_id
  records = [tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.fqdn]
}

resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = local.jenkins_dns_fqdn
  type    = "A"

  alias {
    name                   = aws_lb.jenkins.dns_name
    zone_id                = aws_lb.jenkins.zone_id
    evaluate_target_health = false
  }
}