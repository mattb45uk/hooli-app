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
    container_port   = 80
  }

}

resource "aws_ecs_task_definition" "hooli" {
  family = "service"
  network_mode = "awsvpc"
  requires_compatibilities = [ "FARGATE" ]
  cpu = "256"
  memory = "512"
  container_definitions = jsonencode([
    {
      name      = "hooli"
      image     = "nginxdemos/hello"
      cpu       = 256
      memory    = 512
      essential = true
      "portMappings": [
                {
                    "containerPort": 80, 
                    "hostPort": 80, 
                    "protocol": "tcp"
                }
            ]
    }
  ])
}
