variable "bucket_name" {
    default = "gallerist-product-media-staging"
}

variable "hosted_zone_id" {
    type    = string
    default = "Z0894110118TOX86LT4AC"
}

variable "hosted_zone" {
    type = string
    default = "gallerist.biz"
}

variable "domain_name" {
    description = "Domain name for staging"
    default = "gallerist.biz"
}

variable "route53_record_name" {
    description = "Record name for cloudfront distribution"
    default = "stage.cdn"
}

variable "alias_zone_id" {
    description = "Hardcoded zonde_id for all cloudfront distribution"
    default = "Z2FDTNDATAQYW2"
}

variable "ttl" {
    default = 60
}
