locals {
    container_definition = [
        {
            name      = "gtd-web-app"
            image     = "${var.web_container_image}"
            cpu       = 1024
            memory    = 2048
            essential = true
            portMappings = [
                {
                containerPort = var.web_frontend_port
                hostPort      = var.web_frontend_port
                }
            ]
            environment=[
                {
                    "name": "VTT_DBPASSWORD"
                    "value":"${random_password.db_password.result}" 
                },
                {
                    "name": "VTT_DBHOST"
                    "value":"${aws_db_instance.gtd_posgres_db.address}"            
                },
                {
                    "name": "VTT_LISTENHOST"
                    "value":"0.0.0.0"            
                }
            ]
            command     = ["serve"]
            logConfiguration = {
                logDriver = "awslogs",
                "options" : {
                "awslogs-region" : var.region,
                "awslogs-group" : "gtd-web-app",
                "awslogs-stream-prefix" : "gtd-web-app",
                # "awslogs-create-group" : "true"
                }
            }
        }
    ]
}

resource "aws_ecs_task_definition" "gtd_web_ecs_td" {
  family                   = "servian-gtd-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = "${aws_iam_role.ecs_task_execution_role.arn}"
  container_definitions = jsonencode(local.container_definition)
}

resource "aws_ecs_cluster" "gtd_web_cluster" {
    name = "gtd_web_cluster"

}

resource "aws_ecs_service" "gtd_web_ecs_service" {
  name            = "gtd-web-service"
  cluster         = aws_ecs_cluster.gtd_web_cluster.id
  task_definition = aws_ecs_task_definition.gtd_web_ecs_td.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.gtd_web_ecs_sg.id]
    subnets         = aws_subnet.web_subnets.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.gtd_ecs_tg.arn
    container_name   = "gtd-web-app"
    container_port   = var.web_frontend_port
  }

  depends_on = [aws_alb_listener.listener_http]
}



resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "gtd-web-app"
  tags = {
    Name = "ecs-web-app"
  }
}

# resource "aws_cloudwatch_log_stream" "cb_log_stream" {
#   name           = "cb-log-stream"
#   log_group_name = aws_cloudwatch_log_group.cb_log_group.name
# }