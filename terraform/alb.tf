# alb.tf
#---------
##### Create ALB Instance
resource "aws_lb" "gtd-alb" {
  name               = "gtd-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]



  tags = {
        Name = "gtd-alb"
    }

}

##### Create ALB Target Group
resource "aws_alb_target_group" "gtd_ecs_tg" {
  name          = "gtd-ecs-alb-target"
  port          = var.web_frontend_port
  protocol      = "HTTP"
  vpc_id        = aws_vpc.gtd_vpc.id
  target_type   = "ip"
  stickiness {
    type = "lb_cookie"
  }
  health_check {
    path = var.health_check_path
    port = var.web_frontend_port
  }
}

##### Creating HTTP Listener
##### HTTPS listner would require a SSL certificate and for it to be tusted by browsers we would need a Public DNS Domain, Add a A record in DNS for a hostname
##### genterate a CSR with the same hostname as the Common name get it signed by a public CA (this can be done via Route53 and Certificate manager)
##### I am sticking with HTTP to make it less complex

resource "aws_alb_listener" "listener_http" {
  depends_on = [
    aws_alb_target_group.gtd_ecs_tg
  ]
  load_balancer_arn = aws_lb.gtd-alb.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.gtd_ecs_tg.arn
    type             = "forward"
  }
}


