terraform {
  backend "s3" {
    bucket = "ecsdemotf"
    key = "ecs-cluster-terraform.tfstate"
    region = "ap-south-1"
    
  }
}