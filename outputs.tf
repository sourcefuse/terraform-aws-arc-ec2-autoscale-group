output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.this.id
}

output "launch_template_name" {
  description = "The name of the launch template"
  value       = aws_launch_template.this.name
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = aws_launch_template.this.arn
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = aws_launch_template.this.latest_version
}

output "launch_template_default_version" {
  description = "The default version of the launch template"
  value       = aws_launch_template.this.default_version
}

output "name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.arn
}

output "asg_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.id
}

output "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = aws_autoscaling_group.this.desired_capacity
}


output "availability_zones" {
  description = "Availability Zones used by the Auto Scaling Group"
  value       = aws_autoscaling_group.this.availability_zones
}

output "enabled_metrics" {
  description = "List of enabled metrics for the ASG"
  value       = aws_autoscaling_group.this.enabled_metrics
}


output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.this.arn
}

output "iam_role_name" {
  description = "The name of the IAM role attached to the instance profile"
  value       = aws_iam_role.this.name
}
