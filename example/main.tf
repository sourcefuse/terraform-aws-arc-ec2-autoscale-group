################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.6"

  environment = terraform.workspace
  project     = "terraform-aws-arc-alb"

  extra_tags = {
    Example = "True"
  }
}

module "asg" {
  source                           = "../"
  launch_template                  = local.launch_template
  asg                              = local.asg_config
  security_group_data              = local.security_group_data
  security_group_name              = local.security_group_name
  vpc_id                           = data.aws_vpc.default.id
  autoscaling_notification_enabled = local.autoscaling_notification_enabled
  autoscaling_notification_types   = local.autoscaling_notification_types
  autoscaling_sns_topic_arn        = local.autoscaling_sns_topic_arn
  schedules                        = local.schedules
  autoscaling_policy               = local.autoscaling_policy
  predictive_scaling_configuration = local.predictive_scaling_configuration
  create_autoscaling_attachment    = local.create_autoscaling_attachment
  autoscaling_attachments          = local.autoscaling_attachments
  instance_profile_name            = local.instance_profile_name
  tags                             = module.tags.tags
}
