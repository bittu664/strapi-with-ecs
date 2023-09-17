terraform {
  backend "s3" {
    bucket = "vpc-for-strapi"
    key = "terraform.tfstate"
    region = "ap-south-1"
    
  }
}