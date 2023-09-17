terraform {
  backend "s3" {
    bucket = "stage-ecsdemo"
    key = "aurora-terraform.tfstate"
    region = "ap-south-1"
    
  }
}