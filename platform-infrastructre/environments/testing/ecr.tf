resource "aws_ecr_repository" "microservices" {
  for_each = local.microservices

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = merge(local.common_tags, {
    Name       = each.value
    Component  = "microservice"
    Repository = "ecr"
  })
}
