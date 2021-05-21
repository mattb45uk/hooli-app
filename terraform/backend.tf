terraform {
  backend "s3" {
    bucket = "hooli-backend-tf"
    key    = "state"
    region = "eu-west-1"
  }
}