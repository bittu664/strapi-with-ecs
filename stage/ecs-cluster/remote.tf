terraform {
  backend "s3" {
    bucket = "stage-ecsdemo"
    key = "ecs-cluster-terraform.tfstate"
    region = "ap-south-1"
    
  }
}