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
  default = "10.0.0.0/16"
}

variable "vpc_azs" {
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}


variable "public_subnet_id" {    
  default = ["subnet-0c2855c67bd4dfc41", "subnet-0c35f4c07a2bd95c0"]
}

variable "private_subnet_id" {    
  default = ["subnet-0ecd4752e7f8782ea", "subnet-0efdea5704687be73"]
}


##### For AWS secret manager ######


variable "secret_name" {    
  default = "strapi-db-prod"
}




### FOR SNS ###

variable "aws_sns_topic_name" {    
  default = "strapi_topics"
}

variable "aws_sns_topic_endpoint" {    
  default = "bittuthakur55512@gmail.com"
}



##### FOR ALB ######


variable "application_load_balancer_name" {    
  default = "strapi-prod-alb"
}

variable "aws_lb_target_group_name" {    
  default = "strapi-prod-tg"
}

variable "acm_certificate_arn" {    
  default = "arn:aws:acm:ap-south-1:782408168927:certificate/d9d4d66e-7a5d-4143-a331-d9fbf851c18b"
}


##### FOR ECS #######

variable "aws_ecs_role_name" {    
  default = "ecs-strapi-prod"
}

variable "database_host_endpoint" {  ### here you need to provide writer endpoint   
  default = "strapi-prod.cluster-c4zcudvf6rx3.ap-south-1.rds.amazonaws.com"
}


variable "aws_ecs_cluster_name" {    
  default = "strapi-production"
}

variable "aws_cloudwatch_log_group_name" {    
  default = "strapi-production-logs"
}

variable "aws_ecs_task_definition_name" {    
  default = "strapi-production"
}

variable "aws_ecs_container_memory" {    
  default = "8192"
}

variable "aws_ecs_container_cpu" {    
  default = "2048"
}

variable "aws_ecs_service_name" {    
  default = "strapi-svc"
}

variable "aws_ecs_service_desired_count" {    
  default = "2"
}









#### ECS Auto Scaling Part

variable "ecs_min_capacity_count" {    
  default = "2"
}

variable "ecs_max_capacity_count" {    
  default = "10"
}

variable "memory_autoscaling_target_value" {    
  default = "80"
}

variable "memory_autoscaling_name" {    
  default = "memory-autoscaling-strapi-prod"
}

variable "cpu_autoscaling_name" {    
  default = "cpu-autoscaling-strapi-prod"
}

variable "cpu_autoscaling_target_value" {    
  default = "80"
}
