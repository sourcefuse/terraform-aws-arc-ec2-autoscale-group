variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID for the resources"
  type        = string
}

variable "security_group_name" {
  type        = string
  description = "alb security group name"
}

variable "security_groups" {
  type    = list(string)
  default = []
}
########## alb security group config ##########
variable "security_group_data" {
  type = object({
    security_group_ids_to_attach = optional(list(string), [])
    create                       = optional(bool, true)
    description                  = optional(string, null)
    ingress_rules = optional(list(object({
      description              = optional(string, null)
      cidr_block               = optional(string, null)
      source_security_group_id = optional(string, null)
      from_port                = number
      ip_protocol              = string
      to_port                  = string
      self                     = optional(bool, false)
    })), [])
    egress_rules = optional(list(object({
      description                   = optional(string, null)
      cidr_block                    = optional(string, null)
      destination_security_group_id = optional(string, null)
      from_port                     = number
      ip_protocol                   = string
      to_port                       = string
      prefix_list_id                = optional(string, null)
    })), [])
  })
  description = "(optional) Security Group data"
  default = {
    create = false
  }
}
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Name        = "arc"
    Environment = "dev"
  }
}


################################################################################
# EC2 Launch Template
################################################################################
variable "launch_template" {
  description = "Configuration for the EC2 Launch Template"
  type = object({
    name          = string
    description   = optional(string)
    image_id      = string
    instance_type = string
    user_data     = optional(string)

    disable_api_stop        = optional(bool)
    default_version         = optional(string)
    update_default_version  = optional(bool)
    disable_api_termination = optional(bool)
    ebs_optimized           = optional(bool)

    block_device_mappings = optional(list(object({
      device_name  = string
      no_device    = optional(string)
      virtual_name = optional(string)
      ebs = optional(object({
        volume_size           = optional(number)
        delete_on_termination = optional(bool)
        encrypted             = optional(bool)
        iops                  = optional(number)
        kms_key_id            = optional(string)
        snapshot_id           = optional(string)
        throughput            = optional(number)
        volume_type           = optional(string)
      }))
    })))

    cpu_options = optional(object({
      core_count       = optional(number)
      amd_sev_snp      = optional(bool)
      threads_per_core = optional(number)
    }))

    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string)
      capacity_reservation_target = optional(object({
        capacity_reservation_id                 = optional(string)
        capacity_reservation_resource_group_arn = optional(string)
      }))
    }))

    credit_specification = optional(object({
      cpu_credits = optional(string)
    }))

    elastic_inference_accelerator = optional(object({
      type = string
    }))

    enclave_options = optional(object({
      enabled = bool
    }))

    hibernation_options = optional(object({
      configured = bool
    }))

    elastic_gpu_specifications = optional(list(object({
      type = string
    })))

    iam_instance_profile = optional(object({
      arn  = optional(string)
      name = optional(string)
    }))

    instance_requirements = optional(object({
      accelerator_count                                       = optional(object({ min = number, max = number }))
      accelerator_manufacturers                               = optional(list(string))
      accelerator_names                                       = optional(list(string))
      accelerator_total_memory_mib                            = optional(object({ min = number, max = number }))
      accelerator_types                                       = optional(list(string))
      allowed_instance_types                                  = optional(list(string))
      bare_metal                                              = optional(string)
      baseline_ebs_bandwidth_mbps                             = optional(object({ min = number, max = number }))
      burstable_performance                                   = optional(string)
      cpu_manufacturers                                       = optional(list(string))
      excluded_instance_types                                 = optional(list(string))
      instance_generations                                    = optional(list(string))
      local_storage                                           = optional(string)
      local_storage_types                                     = optional(list(string))
      max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number)
      memory_gib_per_vcpu                                     = optional(object({ min = number, max = number }))
      memory_mib                                              = optional(object({ min = number, max = number }))
      network_interface_count                                 = optional(object({ min = number, max = number }))
      on_demand_max_price_percentage_over_lowest_price        = optional(number)
      require_hibernate_support                               = optional(bool)
      spot_max_price_percentage_over_lowest_price             = optional(number)
      total_local_storage_gb                                  = optional(object({ min = number, max = number }))
      vcpu_count                                              = optional(object({ min = number, max = number }))
    }))

    kernel_id                            = optional(string)
    ram_disk_id                          = optional(string)
    instance_initiated_shutdown_behavior = optional(string)

    monitoring = optional(object({
      enabled = bool
    }))

    maintenance_options = optional(object({
      auto_recovery = string
    }))

    license_specification = optional(object({
      license_configuration_arn = optional(string)
    }))

    instance_market_options = optional(object({
      market_type = string
      spot_options = optional(object({
        block_duration_minutes         = optional(number)
        instance_interruption_behavior = optional(string)
        max_price                      = optional(string)
        spot_instance_type             = optional(string)
        valid_until                    = optional(string)
      }))
    }))

    network_interfaces = optional(list(object({
      associate_public_ip_address = optional(bool)
      description                 = optional(string)
      device_index                = optional(number)
      interface_type              = optional(string)
      ipv4_prefixes               = optional(list(string))
      ipv4_prefix_count           = optional(number)
      ipv4_address_count          = optional(number)
      ipv6_prefix_count           = optional(number)
      ipv6_prefixes               = optional(list(string))
      ipv4_addresses              = optional(list(string))
      ipv6_addresses              = optional(list(string))
      ipv6_address_count          = optional(number)
      network_interface_id        = optional(string)
      network_card_index          = optional(number)
      private_ip_address          = optional(string)
      primary_ipv6                = optional(bool)
      security_groups             = optional(list(string))
      subnet_id                   = optional(string)
      delete_on_termination       = optional(bool)
      connection_tracking_specification = optional(object({
        tcp_established_timeout = optional(number)
        udp_stream_timeout      = optional(number)
        udp_timeout             = optional(number)
      }))
    })))

    metadata_options = optional(object({
      http_endpoint               = optional(string)
      http_tokens                 = optional(string)
      http_put_response_hop_limit = optional(number)
      http_protocol_ipv6          = optional(string)
      instance_metadata_tags      = optional(string)
    }))

    placement = optional(object({
      availability_zone       = optional(string)
      affinity                = optional(string)
      group_name              = optional(string)
      host_id                 = optional(string)
      host_resource_group_arn = optional(string)
      partition_number        = optional(number)
      spread_domain           = optional(string)
      tenancy                 = optional(string)
    }))
    private_dns_name_options = optional(object({
      enable_resource_name_dns_a_record    = optional(bool)
      enable_resource_name_dns_aaaa_record = optional(bool)
      hostname_type                        = optional(string)
    }))
    tag_specifications = optional(object({
      resource_type = optional(string)
      tags          = optional(string)
    }))
  })
}


variable "asg" {
  description = "Configuration map for Auto Scaling Group"
  type = object({
    name                      = optional(string)
    min_size                  = number
    max_size                  = number
    desired_capacity          = optional(number)
    desired_capacity_type     = optional(string)
    vpc_zone_identifier       = optional(list(string))
    availability_zones        = optional(list(string))
    min_elb_capacity          = optional(number)
    wait_for_elb_capacity     = optional(number)
    wait_for_capacity_timeout = optional(string)
    capacity_rebalance        = optional(bool)
    context                   = optional(string)
    placement_group           = optional(string)
    health_check_type         = optional(string)
    health_check_grace_period = optional(number)
    protect_from_scale_in     = optional(bool)
    default_cooldown          = optional(number)
    default_instance_warmup   = optional(number)
    force_delete              = optional(bool)
    max_instance_lifetime     = optional(number)
    metrics_granularity       = optional(string)
    enabled_metrics           = optional(list(string))
    termination_policies      = optional(list(string))
    suspended_processes       = optional(list(string))
    service_linked_role_arn   = optional(string)
    instance_generations      = optional(bool)
    tags                      = optional(list(map(string)))

    availability_zone_distribution = optional(object({
      capacity_distribution_strategy = string
    }))

    initial_lifecycle_hook = optional(list(object({
      name                    = string
      lifecycle_transition    = string
      default_result          = optional(string)
      heartbeat_timeout       = optional(number)
      notification_metadata   = optional(string)
      notification_target_arn = optional(string)
      role_arn                = optional(string)
    })))

    instance_maintenance_policy = optional(object({
      min_healthy_percentage = optional(number)
      max_healthy_percentage = optional(number)
    }))

    mixed_instances_policy = optional(object({
      launch_template = object({
        launch_template_specification = object({
          version = string
        })
        override = optional(list(object({
          instance_type     = optional(string)
          weighted_capacity = optional(string)
          instance_requirements = optional(object({
            accelerator_count = optional(object({
              min = number,
              max = number
            })),
            accelerator_manufacturers = optional(list(string)),
            accelerator_names         = optional(list(string)),
            accelerator_total_memory_mib = optional(object({
              min = number,
              max = number
            })),
            accelerator_types      = optional(list(string)),
            allowed_instance_types = optional(list(string)),
            bare_metal             = optional(string),
            baseline_ebs_bandwidth_mbps = optional(object({
              min = number,
              max = number
            })),
            burstable_performance                                   = optional(string),
            cpu_manufacturers                                       = optional(list(string)),
            excluded_instance_types                                 = optional(list(string)),
            instance_generations                                    = optional(list(string)),
            local_storage                                           = optional(string),
            local_storage_types                                     = optional(list(string)),
            max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number),
            memory_gib_per_vcpu = optional(object({
              min = number,
              max = number
            })),
            memory_mib = optional(object({
              min = number,
              max = number
            })),
            network_bandwidth_gbps = optional(object({
              min = number,
              max = number
            })),
            network_interface_count = optional(object({
              min = number,
              max = number
            })),
            on_demand_max_price_percentage_over_lowest_price = optional(number),
            require_hibernate_support                        = optional(bool),
            spot_max_price_percentage_over_lowest_price      = optional(number),
            total_local_storage_gb = optional(object({
              min = number,
              max = number
            })),
            vcpu_count = optional(object({
              min = number,
              max = number
            }))
          }))
        })))
      })

      instances_distribution = optional(object({
        on_demand_allocation_strategy            = optional(string)
        on_demand_base_capacity                  = optional(number)
        on_demand_percentage_above_base_capacity = optional(number)
        spot_allocation_strategy                 = optional(string)
        spot_instance_pools                      = optional(number)
        spot_max_price                           = optional(string)
      }))
    }))

    warm_pool = optional(object({
      max_group_prepared_capacity = optional(number)
      min_size                    = optional(number)
      pool_state                  = optional(string)
      instance_reuse_policy = optional(object({
        reuse_on_scale_in = optional(bool)
      }))
    }))

    instance_refresh = optional(list(object({
      strategy = string
      triggers = optional(list(string))
      preferences = optional(object({
        checkpoint_delay             = optional(number)
        checkpoint_percent           = optional(number)
        instance_warmup              = optional(number)
        min_healthy_percentage       = optional(number)
        max_healthy_percentage       = optional(number)
        scale_in_protected_instances = optional(string)
        standby_instances            = optional(string)
        auto_rollback                = optional(bool)
      }))
    })))
  })
}

################################################################################
# Auto Scaling traffic source attachment
################################################################################
variable "traffic_sources" {
  description = "List of traffic sources to attach to the Auto Scaling group"
  type = list(object({
    identifier = string
    type       = string
  }))
  default = []
}

variable "create_traffic_source_attachment" {
  description = "Whether to create traffic source attachment for the auto scaling group"
  type        = bool
  default     = false
}
################################################################################
# Auto Scaling notification
################################################################################
variable "autoscaling_notification_enabled" {
  description = "Boolean flag to enable or disable autoscaling notifications"
  type        = bool
  default     = false
}

variable "autoscaling_notification_types" {
  description = "List of notification types for the Auto Scaling group"
  type        = list(string)
  default = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
}

variable "autoscaling_sns_topic_arn" {
  description = "ARN of the SNS topic to send Auto Scaling notifications to"
  type        = string
}

################################################################################
# Auto Scaling schedule
################################################################################
variable "schedules" {
  description = "List of Auto Scaling schedules"
  type = list(object({
    scheduled_action_name = string
    desired_capacity      = optional(number)
    min_size              = optional(number)
    max_size              = optional(number)
    start_time            = optional(string)
    end_time              = optional(string)
    recurrence            = optional(string)
    time_zone             = optional(string)
  }))
  default = []
}

################################################################################
# Auto Scaling policy
################################################################################
variable "autoscaling_policy" {
  description = "Configuration for the autoscaling policy"
  type = object({
    name                      = optional(string)
    policy_type               = optional(string)
    adjustment_type           = optional(string)
    cooldown                  = optional(number)
    estimated_instance_warmup = optional(number)
    scaling_adjustment        = optional(number)
    metric_aggregation_type   = optional(string)
    min_adjustment_magnitude  = optional(number)

    step_adjustment = optional(list(object({
      scaling_adjustment          = number
      metric_interval_lower_bound = optional(number)
      metric_interval_upper_bound = optional(number)
    })))

    target_tracking_configuration = optional(object({
      disable_scale_in = optional(bool)
      target_value     = optional(number)

      predefined_metric_specification = optional(object({
        predefined_metric_type = string
        resource_label         = optional(string)
      }))

      customized_metric_specification = optional(object({
        metric_name = string
        namespace   = string
        statistic   = string
        unit        = optional(string)

        metric_dimension = optional(list(object({
          name  = string
          value = string
        })))
      }))
    }))
  })
  default = {}
}


variable "predictive_scaling_configuration" {
  description = "Predictive scaling configuration"
  type = object({
    mode                         = optional(string)
    scheduling_buffer_time       = optional(number)
    max_capacity_breach_behavior = optional(string)
    max_capacity_buffer          = optional(number)

    metric_specification = list(object({
      target_value = number

      predefined_metric_pair_specification = optional(object({
        predefined_metric_type = string
        resource_label         = optional(string)
      }))

      predefined_load_metric_specification = optional(object({
        predefined_metric_type = string
        resource_label         = optional(string)
      }))

      predefined_scaling_metric_specification = optional(object({
        predefined_metric_type = string
        resource_label         = optional(string)
      }))

      customized_scaling_metric_specification = optional(object({
        metric_data_queries = list(object({
          id          = string
          expression  = optional(string)
          label       = optional(string)
          return_data = optional(bool)

          metric_stat = optional(object({
            stat = string
            unit = optional(string)

            metric = object({
              metric_name = string
              namespace   = string
              dimensions = optional(list(object({
                name  = string
                value = string
              })))
            })
          }))
        }))
      }))

      customized_load_metric_specification = optional(object({
        metric_data_queries = list(object({
          id          = string
          expression  = optional(string)
          label       = optional(string)
          return_data = optional(bool)

          metric_stat = optional(object({
            stat = string
            unit = optional(string)

            metric = object({
              metric_name = string
              namespace   = string
              dimensions = optional(list(object({
                name  = string
                value = string
              })))
            })
          }))
        }))
      }))

      customized_capacity_metric_specification = optional(object({
        metric_data_queries = list(object({
          id          = string
          expression  = optional(string)
          label       = optional(string)
          return_data = optional(bool)

          metric_stat = optional(object({
            stat = string
            unit = optional(string)

            metric = object({
              metric_name = string
              namespace   = string
              dimensions = optional(list(object({
                name  = string
                value = string
              })))
            })
          }))
        }))
      }))
    }))
  })
  default = null
}


################################################################################
# Auto Scaling attachment
################################################################################
variable "create_autoscaling_attachment" {
  description = "Whether to create autoscaling attachments"
  type        = bool
  default     = false
}
variable "autoscaling_attachments" {
  description = "Map of autoscaling attachment configurations"
  type = map(object({
    autoscaling_group_name = string
    lb_target_group_arn    = optional(string)
    elb                    = optional(string)
  }))
  default = {}
}

variable "instance_profile_name" {
  description = "The name of the IAM instance profile"
  type        = string
  default     = "asg-instance-profile"
}
