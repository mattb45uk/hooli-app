resource "aws_ecr_repository" "hooli" {
  name                 = "hooli-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}