resource "aws_security_group" "prometheus_sg" {
  name_prefix = "${var.prometheus_service_name}-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = var.prometheus_port
    to_port   = var.prometheus_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change to restrict access
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_ecs_task_definition" "prometheus_task" {
  family                   = "prometheus-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.prometheus_service_name
      image     = "prom/prometheus:latest"
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = var.prometheus_port
          hostPort      = var.prometheus_port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "prometheus_service" {
  name            = "${var.prometheus_service_name}-service"
  cluster        = module.ecs[0].cluster_id
  task_definition = aws_ecs_task_definition.prometheus_task.arn
  launch_type    = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.prometheus_sg.id]
    assign_public_ip = true
  }

  desired_count = 1

  tags = {
    Name = "${var.prometheus_service_name}-service"
  }
}