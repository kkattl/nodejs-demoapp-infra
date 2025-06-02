output "alb_dns" {
  value = aws_lb.public.dns_name
}

output "asg_name" {
  value = module.asg.autoscaling_group_name
}
