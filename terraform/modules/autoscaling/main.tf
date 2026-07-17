locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_autoscaling_group" "app" {
  name = "${var.project_name}-${var.environment}-asg"

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  vpc_zone_identifier = var.app_subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  default_cooldown          = 300
  force_delete              = true
  wait_for_capacity_timeout = "10m"

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, {
      Name = "${var.project_name}-${var.environment}-app"
      Tier = "application"
    })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 180
    }

  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "target_tracking_cpu" {
  name                   = "${var.project_name}-${var.environment}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60
  }
}

resource "aws_autoscaling_notification" "events" {
  group_names = [
    aws_autoscaling_group.app.name
  ]

  topic_arn = var.sns_topic_arn

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
}
