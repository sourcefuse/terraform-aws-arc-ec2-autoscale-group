output "launch_template_id" {
  description = "The ID of the launch template"
  value       = module.asg.launch_template_id
}

output "launch_template_name" {
  description = "The name of the launch template"
  value       = module.asg.launch_template_name
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = module.asg.launch_template_arn
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = module.asg.launch_template_latest_version
}

output "name" {
  description = "Name of the Auto Scaling Group"
  value       = module.asg.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.asg.asg_arn
}

output "asg_id" {
  description = "ID of the Auto Scaling Group"
  value       = module.asg.asg_id
}

output "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = module.asg.desired_capacity
}


output "availability_zones" {
  description = "Availability Zones used by the Auto Scaling Group"
  value       = module.asg.availability_zones
}

output "enabled_metrics" {
  description = "List of enabled metrics for the ASG"
  value       = module.asg.enabled_metrics
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = module.asg.iam_instance_profile_arn
}
