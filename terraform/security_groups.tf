##### Create Security Group for ALB
resource "aws_security_group" "lb_sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.gtd_vpc.id

  ingress {
    description      = "HTTP traffic from Internet"
    from_port        = var.alb_port
    to_port          = var.alb_port
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
        Name = "LoadBalancer_SecurityGroup"
    }
}

###### Create DB Security Group

resource "aws_security_group" "db_sg" {
  name        = "allow_postgress_from_web"
  description = "Allow inbound DB request from web containers"
  vpc_id      = aws_vpc.gtd_vpc.id

  ingress {
    description      = "DB connections from the Web containers"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = var.web_subnets_cidr
  }

  tags = {
        Name = "Database_SecurityGroup"
    }
}

##### Create ECS Task Security Group
resource "aws_security_group" "gtd_web_ecs_sg" {
  name        = "gtd-web-security-group"
  vpc_id      = aws_vpc.gtd_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = var.web_frontend_port
    to_port         = var.web_frontend_port
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "ECS_SecurityGroup"
    }
}