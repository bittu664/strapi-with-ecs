terraform {
  backend "s3" {
    bucket = "ecsdemotf"
    key = "aurora-terraform.tfstate"
    region = "ap-south-1"
    
  }
}