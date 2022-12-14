# autoscal.tf
#------------

#### Create IAM role for autoscaling
resource "aws_iam_role" "ecs-autoscale-role" {

  name = "ecs-gtd-web-autoscale-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

##### Attached AWS managed autoscale permissions to IAM role
resource "aws_iam_role_policy_attachment" "ecs-autoscale" {

  role = aws_iam_role.ecs-autoscale-role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

#### Create AWS autoscale target
resource "aws_appautoscaling_target" "ecs_gtd_web_as_target" {

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.gtd_web_cluster.name}/${aws_ecs_service.gtd_web_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.ecs-autoscale-role.arn
}

#### Define autoscaling policy
resource "aws_appautoscaling_policy" "ecs_target_cpu" {
    count = var.enable_autoscaling ? 1:0
  name               = "application-scaling-policy-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_gtd_web_as_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_gtd_web_as_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_gtd_web_as_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 80
  }
  depends_on = [aws_appautoscaling_target.ecs_gtd_web_as_target]
}
