
terraform {
  backend "s3" {
    bucket         = "backend-projects"
    key            = "terraform2key"
    region         = "eu-west-2"
  }
}