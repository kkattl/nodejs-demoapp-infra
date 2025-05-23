resource "aws_cloudwatch_metric_alarm" "high_req" {
  alarm_name          = "${var.project_name}-${var.environment}-high-req"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 200

  dimensions = {
    TargetGroup  = aws_lb_target_group.app.arn_suffix
    LoadBalancer = aws_lb.public.arn_suffix
  }

  alarm_actions = length(var.alert_email) > 0 ? [aws_sns_topic.alerts[0].arn] : []
}
