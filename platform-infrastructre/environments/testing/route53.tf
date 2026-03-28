resource "aws_route53_zone" "platform_public" {
  name = var.platform_domain_name

  tags = merge(local.common_tags, {
    Name = var.platform_domain_name
  })
}
