resource "aws_route53_record" "ctdc-www-record" {
  zone_id = var.route53_zone_id
  name    = "www.connectingthedotscorp.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.ctdc-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.ctdc-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ctdc-root-record" {
  zone_id = var.route53_zone_id
  name    = "connectingthedotscorp.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.ctdc-redirect-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.ctdc-redirect-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
