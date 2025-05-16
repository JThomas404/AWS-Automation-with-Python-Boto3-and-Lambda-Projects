resource "aws_cloudfront_origin_access_control" "ctdc-oac" {
  name                              = "ctdc-oac"
  description                       = "Origin Access Control for ConnectingTheDots S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "ctdc-distribution" {
  aliases             = ["www.connectingthedotscorp.com"]
  enabled             = true
  comment             = "CDN for Connecting The Dots Static Website"
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.ctdc-s3-bucket.bucket_regional_domain_name
    origin_id                = "ctdc-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.ctdc-oac.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ctdc-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = var.project_tag
  }

  depends_on = [aws_cloudfront_origin_access_control.ctdc-oac]
}

resource "aws_cloudfront_distribution" "ctdc-redirect-distribution" {
  aliases             = ["connectingthedotscorp.com"]
  enabled             = true
  comment             = "Redirect distribution for root domain to www"
  default_root_object = "index.html"

  origin {
    domain_name = "${aws_s3_bucket.ctdc-root-redirect.bucket}.s3-website.${var.region}.amazonaws.com"
    origin_id   = "ctdc-root-redirect-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "ctdc-root-redirect-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = var.project_tag
  }
}

resource "aws_s3_bucket" "ctdc-root-redirect" {
  bucket = "connectingthedotscorp.com"

  tags = {
    Name = var.project_tag
  }
}

resource "aws_s3_bucket_website_configuration" "ctdc-root-redirect-config" {
  bucket = aws_s3_bucket.ctdc-root-redirect.id

  redirect_all_requests_to {
    host_name = "www.connectingthedotscorp.com"
    protocol  = "https"
  }
}

data "aws_iam_policy_document" "ctdc-cloudfront-oac" {
  statement {
    sid    = "AllowCloudFrontAccess"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.ctdc-s3-bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::533267010082:distribution/${aws_cloudfront_distribution.ctdc-distribution.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "ctdc-oac-access" {
  bucket = aws_s3_bucket.ctdc-s3-bucket.id
  policy = data.aws_iam_policy_document.ctdc-cloudfront-oac.json

  depends_on = [
    aws_s3_bucket.ctdc-s3-bucket,
    random_id.ctdc-random-number
  ]
}

