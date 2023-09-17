variable "aws-profile" {
  default = "ecsdemo"
}

variable "region" {
  default = "ap-south-1"
}


variable "environment" {    
  default = "prod"
}

############# FOR VPC #################



variable "vpc_id" {
  default = "vpc-04cbc067dd9cbfe8e"
}

variable "vpc_cidr" {
  default = ["10.0.0.0/16"]
}

variable "vpc_azs" {
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "public_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}



##### For AWS secret manager ######


variable "secret_name" {    
  default = "strapi-db-prod"
}


#### FOR Aurora DB #########

variable "cluster_identifier_name" {    
  default = "strapi-prod"
}

variable "db_engine" {    
  default = "aurora-postgresql"
}

variable "private_subnet_id" {    
  default = ["subnet-0ecd4752e7f8782ea", "subnet-0efdea5704687be73"]
}

variable "engine_version" {    
  default = "14.6"
}

variable "instance_class" {    
  default = "db.t3.medium"
}


variable "db_subnet_group_name" {    
  default = "strapi-subnet-group"
}

variable "rds_security_group_name" {    
  default = "rds-postgres-prod-sg"
}

variable "aurora_availability_zones" {
  default = ["ap-south-1b", "ap-south-1c"]
}

variable "database_name" {    
  default = "postgres"
}

