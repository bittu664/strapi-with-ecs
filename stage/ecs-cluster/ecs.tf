###  ECS SECTION STARTED ##########


resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = var.aws_ecs_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy1" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

  
  
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy2" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"

  
  
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy3" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"

  
}





#### ECS MAIN CLUSTER CREATION PART ###########

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = var.aws_ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Terraform = "true"
    Environment = var.environment
  }

  
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name = aws_ecs_cluster.aws-ecs-cluster.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}



resource "aws_cloudwatch_log_group" "log-group" {
  name = var.aws_cloudwatch_log_group_name

  

  
}


# Define a data source to fetch the Secrets Manager secret
data "aws_secretsmanager_secret" "db_credentials" {
  name = var.secret_name # Replace with your Secrets Manager secret name
}

# Define a data source to fetch the latest version of the secret
data "aws_secretsmanager_secret_version" "latest" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}



resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = var.aws_ecs_task_definition_name

  container_definitions = jsonencode([
  
    {
            "name": "strapi",
            "image": "${var.starpi_ecr_image}",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "strapi-tcp",
                    "containerPort": 1337,
                    "hostPort": 1337,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [
                {
                    "name": "DATABASE_PORT",
                    "value": "5432"
                },
                {
                    "name": "DATABASE_HOST",
                    "value": "${var.database_host_endpoint}"
                },
                {
                    "name": "DATABASE_NAME",
                    "value": "${jsondecode(data.aws_secretsmanager_secret_version.latest.secret_string)["DATABASE_NAME"]}"
                },
                {
                    "name": "DATABASE_USERNAME",
                    "value": "${jsondecode(data.aws_secretsmanager_secret_version.latest.secret_string)["DATABASE_USERNAME"]}"
                },
                {
                    "name": "DATABASE_PASSWORD",
                    "value": "${jsondecode(data.aws_secretsmanager_secret_version.latest.secret_string)["DATABASE_PASSWORD"]}"
                },
                {
                    "name": "DATABASE_SSL",
                    "value": "false"
                },
                 {
                    "name": "JWT_SECRET",
                    "value": "${jsondecode(data.aws_secretsmanager_secret_version.latest.secret_string)["JWT_SECRET"]}"
                },

            ],
            "environmentFiles": [],
            "mountPoints": [],
            "volumesFrom": [],
            "ulimits": [],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
                    "awslogs-region": "${var.region}",
                    "awslogs-stream-prefix": "${var.awslogs_stream_prefix}"
                },
                "secretOptions": []
            }
    }
  ])
  

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.aws_ecs_container_memory
  cpu                      = var.aws_ecs_container_cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Terraform = "true"
    Environment = var.environment
  }

  
}


data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}


### security group for elbs

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = var.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443 
    to_port          = 443  
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Terraform = "true"
    Environment = var.environment
  }

  
}



### security group config for ecs

resource "aws_security_group" "service_security_group" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
  }

  
}



### elb target group

resource "aws_lb_target_group" "target_group" {
  name        = var.aws_lb_target_group_name
  port        = 1337
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
  }

  
}





## application elbs

resource "aws_alb" "application_load_balancer" {
  name               = var.application_load_balancer_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_id
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Terraform = "true"
    Environment = var.environment
  }
  
  

}




### ALB listner sections.....

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  
}


resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"  
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
  depends_on = [aws_lb_listener.listener]
}



#### Creating ECS Service......

resource "aws_ecs_service" "aws-ecs-service" {
  name                 = var.aws_ecs_service_name
  cluster              = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition      = aws_ecs_task_definition.aws-ecs-task.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = var.aws_ecs_service_desired_count
  force_new_deployment = true

  network_configuration {
    subnets          = var.private_subnet_id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.listener_https]
}


### NOW AUTOSCALING PART STARTED........


###Auto Scaling Group

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.ecs_max_capacity_count
  min_capacity       = var.ecs_min_capacity_count
  resource_id        = "service/${aws_ecs_cluster.aws-ecs-cluster.name}/${aws_ecs_service.aws-ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = var.memory_autoscaling_name
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = var.memory_autoscaling_target_value

  }

  
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = var.cpu_autoscaling_name
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = var.cpu_autoscaling_target_value
  }

  
}






