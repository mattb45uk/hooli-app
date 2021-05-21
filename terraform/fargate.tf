resource "aws_ecs_cluster" "hooli" {
  name = "hooli"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "hooli" {
  name            = "hooli"
  cluster         = aws_ecs_cluster.hooli.id
  task_definition = aws_ecs_task_definition.hooli.arn
  desired_count   = 3
  launch_type = "FARGATE"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
        security_groups = [
            "${aws_security_group.lb_sg.id}"
        ]
        subnets = module.vpc.private_subnets
        assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_blue.arn
    container_name   = "hooli"
    container_port   = 8080
  }

}

resource "aws_ecs_task_definition" "hooli" {
  family = "service"
  network_mode = "awsvpc"
  requires_compatibilities = [ "FARGATE" ]
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.exectution.arn
  container_definitions = jsonencode([
    {
      name      = "hooli"
      image     = "904672846176.dkr.ecr.eu-west-1.amazonaws.com/hooli-app:latest"
      cpu       = 256
      memory    = 512
      essential = true
      "portMappings": [
                {
                    "containerPort": 8080, 
                    "hostPort": 8080, 
                    "protocol": "tcp"
                }
            ]
    }
  ])
}

resource "local_file" "taskspec" {
    content     = <<EOF
{
    "family": "service",
    "executionRoleArn": ${aws_iam_role.exectution.arn},
    "containerDefinitions": [
    {
      "name": "hooli",
      "image": "904672846176.dkr.ecr.eu-west-1.amazonaws.com/hooli-app:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
                {
                    "containerPort": 8080, 
                    "hostPort": 8080, 
                    "protocol": "tcp"
                }
            ]
    }
  ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "networkMode": "awsvpc",
    "memory": "512",
    "cpu": "256"
}
EOF
    filename = "${path.module}/../taskdef.json"
}

resource "local_file" "appspec" {
    content     = <<EOF
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: "${aws_ecs_task_definition.hooli.arn}"
        LoadBalancerInfo:
          ContainerName: "hooli"
          ContainerPort: 8080
EOF
    filename = "${path.module}/../appspec.yml"
}

resource "aws_iam_role" "exectution" {
  name = "exectution_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
})

  inline_policy {
    name = "my_inline_policy"
    policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
})
}
}