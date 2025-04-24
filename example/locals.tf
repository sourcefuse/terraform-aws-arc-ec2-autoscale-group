locals {
  security_group_name   = "arc-asg-sg"
  instance_profile_name = "asg-instance-profile"
  security_group_data = {
    create      = true
    description = "Security Group for asg"
    ingress_rules = [
      {
        description = "Allow VPC traffic"
        cidr_block  = "0.0.0.0/0" # Changed to string
        from_port   = 0
        ip_protocol = "tcp"
        to_port     = 443
      },
      {
        description = "Allow traffic from self"
        self        = true
        from_port   = 80
        ip_protocol = "tcp"
        to_port     = 80
      },
    ]
    egress_rules = [
      {
        description = "Allow all outbound traffic"
        cidr_block  = "0.0.0.0/0" # Changed to string
        from_port   = -1
        ip_protocol = "-1"
        to_port     = -1
      }
    ]
  }

  launch_template = {
    name          = "my-launch-template"
    description   = "Example launch template for EC2"
    image_id      = data.aws_ami.amazon_linux.id # Replace with a valid AMI ID
    instance_type = "t3.micro"

    user_data = <<-EOT
  #!/bin/bash
  echo Hello from EC2 > /var/tmp/hello.txt
EOT

    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 8
          delete_on_termination = true
          volume_type           = "gp3"
        }
      }
    ]

    monitoring = {
      enabled = true
    }

    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
    }

    placement = {
      availability_zone = "us-east-1a"
    }
  }

  asg_config = {
    name             = "example-asg"
    min_size         = 1
    max_size         = 5
    desired_capacity = 2

    vpc_zone_identifier       = tolist(data.aws_subnets.private.ids)
    health_check_type         = "EC2"
    wait_for_capacity_timeout = "15m"
    health_check_grace_period = 300
    protect_from_scale_in     = true
    default_cooldown          = 300
    default_instance_warmup   = 120
    force_delete              = false
    capacity_rebalance        = true
    termination_policies      = ["OldestInstance", "ClosestToNextInstanceHour"]


    # Setting instance maintenance policy
    instance_maintenance_policy = {
      min_healthy_percentage = 90
      max_healthy_percentage = 110
    }

    initial_lifecycle_hook = [
      {
        name                 = "my-hook"
        lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
        default_result       = "CONTINUE"
        heartbeat_timeout    = 300
      }
    ]

    mixed_instances_policy = {

      launch_template = {
        launch_template_specification = {
          version = "$Latest"
        }
        override = [
          {
            instance_type     = "t3.medium"
            weighted_capacity = "3"
          },
          {
            instance_type     = "t3.large"
            weighted_capacity = "2"
          }
        ]
      }

      instances_distribution = {
        on_demand_base_capacity                  = 1
        on_demand_percentage_above_base_capacity = 50
        spot_allocation_strategy                 = "capacity-optimized"
      }
    }

    instance_refresh = [
      {
        strategy = "Rolling" # You can change to "Rolling" or "Rebalance" depending on your needs
        triggers = ["tag"]

        preferences = {
          instance_warmup              = 120
          min_healthy_percentage       = 80
          scale_in_protected_instances = "Ignore"
        }
      }
    ]
  }


  autoscaling_notification_enabled = false

  autoscaling_notification_types = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  autoscaling_sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:test"

  schedules = [
    {
      scheduled_action_name = "scale-up-morning"
      desired_capacity      = 4
      min_size              = 2
      max_size              = 6
      recurrence            = "0 6 * * *"
      time_zone             = "UTC"
    },
    {
      scheduled_action_name = "scale-down-evening"
      desired_capacity      = 1
      min_size              = 1
      max_size              = 2
      recurrence            = "0 18 * * *"
      time_zone             = "UTC"
    }
  ]



  autoscaling_policy = {
    name                      = "scale-on-network-out"
    policy_type               = "TargetTrackingScaling"
    estimated_instance_warmup = 300

    target_tracking_configuration = {
      disable_scale_in = false
      target_value     = 1000000.0

      predefined_metric_specification = {
        predefined_metric_type = "ASGAverageNetworkOut"
        # Optional: Only needed for metrics like ALBRequestCountPerTarget
        # resource_label         = "app/my-alb/1234567890abcdef/targetgroup/my-target-group/abcdef123456"
      }
    }
  }



  predictive_scaling_configuration = {
    mode                         = "ForecastAndScale"
    scheduling_buffer_time       = 300
    max_capacity_breach_behavior = "IncreaseMaxCapacity"
    max_capacity_buffer          = 5

    metric_specification = [
      {
        target_value = 60.0

        predefined_metric_pair_specification = {
          predefined_metric_type = "ASGCPUUtilization"
        }

        predefined_scaling_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }

        predefined_load_metric_specification = {
          predefined_metric_type = "ASGTotalNetworkOut"
        }
      }
    ]
  }
  create_autoscaling_attachment = false
  autoscaling_attachments = {
    attach-app1 = {
      autoscaling_group_name = "example-asg"
      alb_target_group_arn   = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/app1-tg/abcd1234efgh5678"
    }
  }

}
