module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc1"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_lb" "hooli" {
  name               = "hooli-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = module.vpc.public_subnets
  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "hooli" {
  load_balancer_arn = aws_lb.hooli.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_blue.arn
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "allow_https"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_lb_target_group" "tg_blue" {
    name        = "tf-hooli-lb-tg-blue"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = module.vpc.vpc_id
}


resource "aws_lb_target_group" "tg_green" {
    name        = "tf-hooli-lb-tg-green"
    port        = 8080
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = module.vpc.vpc_id
}

