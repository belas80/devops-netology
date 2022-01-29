terraform {
  backend "s3" {
    bucket = "tf-mystates"
    key    = "main/terraform.tfstate"
    region = "eu-central-1"
  }
}