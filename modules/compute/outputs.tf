output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.app_alb.arn
}

output "alb_target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = aws_lb_target_group.app_tg.arn
}

output "alb_listener_arn" {
  description = "ARN of the ALB Listener"
  value       = aws_lb_listener.http.arn
}

output "alb_security_group_id" {
  description = "Security Group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.autoscaling.autoscaling_group_name
}

output "launch_template_id" {
  description = "ID of the EC2 launch template"
  value       = module.autoscaling.launch_template_id
}

output "ec2_sg_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}