## AWS CloudFront configuration using Terraform with ACM certificate on different region, ACM validation, S3 Bucket, Route53 records
This is example which will create a cloudfront distribution(in eu-central-1) for a service alongside ACM creation on different region(us-east-1 as it is only supported fegion) and validatng it using DNS validation, adding records to Route53, Creating distribution s3 bucket for CloudFront origin. (And all using Terraform)

To know on details please checkout my article: [Configure AWS CloudFront CDN With Certificate Using Terraform](https://scanskill.com/devops/terraform/cloudfront-cdn-with-certificate-using-terraform/) 