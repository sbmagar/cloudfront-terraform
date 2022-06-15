# Certificate Request for cloudfront distribution custom domain configuration
provider "aws" {
  alias   = "us_east"
  region  = "us-east-1"
#   profile = var.profile
}

# resource "aws_route53_zone" "zone"{
#   name = "unknown"
# }

resource "aws_acm_certificate" "cloudfront_cdn" {
  provider  = aws.us_east
  domain_name = "*.cdn.${var.domain_name}"
  validation_method = "DNS"

  tags = {
      name = "certificate for cloudfront distribution"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  name         = var.domain_name
  private_zone = false
}

# DNS validation
resource "aws_route53_record" "record_validation" {
  # zone_id  = var.hosted_zone_id
  zone_id = data.aws_route53_zone.zone.id
  name    = tolist(aws_acm_certificate.cloudfront_cdn.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cloudfront_cdn.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.cloudfront_cdn.domain_validation_options)[0].resource_record_value]
  ttl     = var.ttl
  allow_overwrite = true
}

# Certificate validation
resource "aws_acm_certificate_validation" "certificate_validation" {
  provider                = aws.us_east
  certificate_arn         = aws_acm_certificate.cloudfront_cdn.arn
  validation_record_fqdns = [aws_route53_record.record_validation.fqdn]
}

# Add product cloudfront distribution
resource "aws_cloudfront_distribution" "product_s3_distribution" {
  origin {
    domain_name = "${var.bucket_name}.s3.amazonaws.com"
    origin_id   = var.bucket_name 
    # s3_origin_config {
    #   origin_access_identity = 
    # }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for staging"
#   default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = "cdflogs.s3.amazonaws.com"
#     prefix          = "cloudfront_logs"
#   }

  # aliases = ["${var.route53_record_name}.${var.domain_name}","${var.staging_domain}"]
  aliases = ["${var.route53_record_name}.${var.domain_name}"]
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.bucket_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
        restriction_type = "none"
    #   restriction_type = "whitelist"
    #   locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    # cloudfront_default_certificate = true
    acm_certificate_arn = aws_acm_certificate.cloudfront_cdn.arn
    ssl_support_method = "sni-only"
  }


  # depends_on = [aws_acm_certificate.cloudfront_cdn, aws_acm_certificate.staging_domain]
  depends_on = [aws_acm_certificate.cloudfront_cdn]
}

resource "aws_route53_record" "a_record" {
    zone_id = var.hosted_zone_id
    name  = "${var.route53_record_name}.${var.domain_name}"
    type  = "A"

    alias {
        name = aws_cloudfront_distribution.product_s3_distribution.domain_name
        zone_id = var.alias_zone_id
        evaluate_target_health = false
    }

    depends_on = [
      aws_cloudfront_distribution.product_s3_distribution
    ]
}