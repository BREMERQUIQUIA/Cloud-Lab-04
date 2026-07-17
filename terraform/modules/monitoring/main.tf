locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-asg-high-cpu"
  alarm_description   = "Average CPU utilization for the Auto Scaling Group is above 80 percent"
  comparison_operator = "GreaterThanThreshold"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic   = "Average"
  period      = 300

  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-asg-high-cpu"
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-hosts"
  alarm_description   = "One or more ALB targets are unhealthy"
  comparison_operator = "GreaterThanThreshold"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Maximum"
  period      = 60

  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 0

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  treat_missing_data = "breaching"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb-unhealthy-hosts"
  })
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Auto Scaling Group CPU"
          view   = "timeSeries"
          region = var.aws_region
          period = 300
          stat   = "Average"

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              var.autoscaling_group_name
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "ALB Target Health"
          view   = "timeSeries"
          region = var.aws_region
          period = 60
          stat   = "Maximum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "LoadBalancer",
              var.alb_arn_suffix,
              "TargetGroup",
              var.target_group_arn_suffix
            ],
            [
              ".",
              "UnHealthyHostCount",
              ".",
              ".",
              ".",
              "."
            ]
          ]
        }
      }
    ]
  })
}
