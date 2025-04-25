################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.85"
    }
  }
}
###################################################################
#                 Security Group
###################################################################
module "arc_security_group" {
  source  = "sourcefuse/arc-security-group/aws"
  version = "0.0.1"

  count         = length(var.security_groups) == 0 ? 1 : 0
  name          = var.security_group_name
  vpc_id        = var.vpc_id
  ingress_rules = var.security_group_data.ingress_rules
  egress_rules  = var.security_group_data.egress_rules

  tags = var.tags
}

################################################################################
# EC2 Launch Template
################################################################################

resource "aws_launch_template" "this" {

  name        = var.launch_template.name
  description = var.launch_template.description

  image_id               = var.launch_template.image_id
  instance_type          = var.launch_template.instance_type
  user_data              = base64encode(var.launch_template.user_data)
  vpc_security_group_ids = [for sg in module.arc_security_group : sg.id]

  disable_api_stop        = var.launch_template.disable_api_stop
  default_version         = var.launch_template.default_version
  update_default_version  = var.launch_template.update_default_version
  disable_api_termination = var.launch_template.disable_api_termination
  ebs_optimized           = var.launch_template.ebs_optimized

  dynamic "block_device_mappings" {
    for_each = var.launch_template.block_device_mappings
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = block_device_mappings.value.no_device
      virtual_name = block_device_mappings.value.virtual_name

      dynamic "ebs" {
        for_each = block_device_mappings.value.ebs != null ? [block_device_mappings.value.ebs] : []
        content {
          volume_size           = ebs.value.volume_size
          delete_on_termination = ebs.value.delete_on_termination
          encrypted             = ebs.value.encrypted
          iops                  = ebs.value.iops
          kms_key_id            = ebs.value.kms_key_id
          snapshot_id           = ebs.value.snapshot_id
          throughput            = ebs.value.throughput
          volume_type           = ebs.value.volume_type
        }
      }
    }
  }

  dynamic "cpu_options" {
    for_each = var.launch_template.cpu_options != null ? [var.launch_template.cpu_options] : []
    content {
      core_count       = cpu_options.value.core_count
      amd_sev_snp      = cpu_options.value.amd_sev_snp
      threads_per_core = cpu_options.value.threads_per_core
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.launch_template.capacity_reservation_specification != null ? [var.launch_template.capacity_reservation_specification] : []
    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference
      dynamic "capacity_reservation_target" {
        for_each = capacity_reservation_specification.value.capacity_reservation_target != null ? [capacity_reservation_specification.value.capacity_reservation_target] : []
        content {
          capacity_reservation_id                 = capacity_reservation_target.value.capacity_reservation_id
          capacity_reservation_resource_group_arn = capacity_reservation_target.value.capacity_reservation_resource_group_arn
        }
      }
    }
  }

  dynamic "credit_specification" {
    for_each = var.launch_template.credit_specification != null ? [var.launch_template.credit_specification] : []
    content {
      cpu_credits = credit_specification.value.cpu_credits
    }
  }

  dynamic "elastic_inference_accelerator" {
    for_each = var.launch_template.elastic_inference_accelerator != null ? [var.launch_template.elastic_inference_accelerator] : []
    content {
      type = elastic_inference_accelerator.value.type
    }
  }

  dynamic "enclave_options" {
    for_each = var.launch_template.enclave_options != null ? [var.launch_template.enclave_options] : []
    content {
      enabled = enclave_options.value.enabled
    }
  }

  dynamic "hibernation_options" {
    for_each = var.launch_template.hibernation_options != null ? [var.launch_template.hibernation_options] : []
    content {
      configured = hibernation_options.value.configured
    }
  }

  dynamic "elastic_gpu_specifications" {
    for_each = var.launch_template.elastic_gpu_specifications != null ? var.launch_template.elastic_gpu_specifications : []
    content {
      type = elastic_gpu_specifications.value.type
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.launch_template.iam_instance_profile != null ? [var.launch_template.iam_instance_profile] : []
    content {
      arn = aws_iam_instance_profile.this.arn
    }
  }

  dynamic "instance_requirements" {
    for_each = var.launch_template.instance_requirements != null ? [var.launch_template.instance_requirements] : []
    content {

      dynamic "accelerator_count" {
        for_each = instance_requirements.value.accelerator_count != null ? [instance_requirements.value.accelerator_count] : []
        content {
          max = accelerator_count.value.max
          min = accelerator_count.value.min
        }
      }

      accelerator_manufacturers = instance_requirements.value.accelerator_manufacturers
      accelerator_names         = instance_requirements.value.accelerator_names

      dynamic "accelerator_total_memory_mib" {
        for_each = instance_requirements.value.accelerator_total_memory_mib != null ? [instance_requirements.value.accelerator_total_memory_mib] : []
        content {
          max = accelerator_total_memory_mib.value.max
          min = accelerator_total_memory_mib.value.min
        }
      }
      accelerator_types      = instance_requirements.value.accelerator_types
      allowed_instance_types = instance_requirements.value.allowed_instance_types
      bare_metal             = instance_requirements.value.bare_metal

      dynamic "baseline_ebs_bandwidth_mbps" {
        for_each = concat(instance_requirements.value.baseline_ebs_bandwidth_mbps, [])
        content {
          max = baseline_ebs_bandwidth_mbps.value.max
          min = baseline_ebs_bandwidth_mbps.value.min
        }
      }

      burstable_performance                                   = instance_requirements.value.burstable_performance
      cpu_manufacturers                                       = instance_requirements.value.cpu_manufacturers
      excluded_instance_types                                 = instance_requirements.value.excluded_instance_types
      instance_generations                                    = instance_requirements.value.instance_generations
      local_storage                                           = instance_requirements.value.local_storage
      local_storage_types                                     = instance_requirements.value.local_storage_types
      max_spot_price_as_percentage_of_optimal_on_demand_price = instance_requirements.value.max_spot_price_as_percentage_of_optimal_on_demand_price

      dynamic "memory_gib_per_vcpu" {
        for_each = instance_requirements.value.memory_gib_per_vcpu != null ? [instance_requirements.value.memory_gib_per_vcpu] : []
        content {
          max = memory_gib_per_vcpu.value.max
          min = memory_gib_per_vcpu.value.min
        }
      }

      dynamic "memory_mib" {
        for_each = [instance_requirements.value.memory_mib]
        content {
          max = memory_mib.value.max
          min = memory_mib.value.min
        }
      }

      dynamic "network_interface_count" {
        for_each = [instance_requirements.value.network_interface_count]
        content {
          max = network_interface_count.value.max
          min = network_interface_count.value.min
        }
      }

      on_demand_max_price_percentage_over_lowest_price = instance_requirements.value.on_demand_max_price_percentage_over_lowest_price
      require_hibernate_support                        = instance_requirements.value.require_hibernate_support
      spot_max_price_percentage_over_lowest_price      = instance_requirements.value.spot_max_price_percentage_over_lowest_price

      dynamic "total_local_storage_gb" {
        for_each = instance_requirements.value.total_local_storage_gb != null ? [instance_requirements.value.total_local_storage_gb] : []
        content {
          max = total_local_storage_gb.value.max
          min = total_local_storage_gb.value.min
        }
      }

      dynamic "vcpu_count" {
        for_each = [instance_requirements.value.vcpu_count]
        content {
          max = vcpu_count.value.max
          min = vcpu_count.value.min
        }
      }
    }
  }

  kernel_id                            = var.launch_template.kernel_id
  ram_disk_id                          = var.launch_template.ram_disk_id
  instance_initiated_shutdown_behavior = var.launch_template.instance_initiated_shutdown_behavior

  dynamic "monitoring" {
    for_each = var.launch_template.monitoring != null ? [var.launch_template.monitoring] : []
    content {
      enabled = monitoring.value.enabled
    }
  }

  dynamic "maintenance_options" {
    for_each = var.launch_template.maintenance_options != null ? [var.launch_template.maintenance_options] : []
    content {
      auto_recovery = maintenance_options.value.auto_recovery
    }
  }

  dynamic "license_specification" {
    for_each = var.launch_template.license_specification != null ? [var.launch_template.license_specification] : []
    content {
      license_configuration_arn = license_specification.value.license_configuration_arn
    }
  }

  dynamic "instance_market_options" {
    for_each = var.launch_template.instance_market_options != null ? [var.launch_template.instance_market_options] : []
    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = instance_market_options.value.spot_options != null ? [instance_market_options.value.spot_options] : []
        content {
          block_duration_minutes         = spot_options.value.block_duration_minutes
          instance_interruption_behavior = spot_options.value.instance_interruption_behavior
          max_price                      = spot_options.value.max_price
          spot_instance_type             = spot_options.value.spot_instance_type
          valid_until                    = spot_options.value.valid_until
        }
      }
    }
  }

  dynamic "network_interfaces" {
    for_each = var.launch_template.network_interfaces != null ? [var.launch_template.network_interfaces] : []
    content {
      associate_public_ip_address = network_interfaces.value.associate_public_ip_address
      description                 = network_interfaces.value.description
      device_index                = network_interfaces.value.device_index
      interface_type              = network_interfaces.value.interface_type
      ipv4_prefixes               = network_interfaces.value.ipv4_prefixes
      ipv4_prefix_count           = network_interfaces.value.ipv4_prefix_count
      ipv4_address_count          = network_interfaces.value.ipv4_address_count
      ipv6_prefix_count           = network_interfaces.value.ipv6_prefix_count
      ipv6_prefixes               = network_interfaces.value.ipv6_prefixes
      ipv4_addresses              = network_interfaces.value.ipv4_addresses
      ipv6_addresses              = network_interfaces.value.ipv6_addresses
      ipv6_address_count          = network_interfaces.value.ipv6_address_count
      network_interface_id        = network_interfaces.value.network_interface_id
      network_card_index          = network_interfaces.value.network_card_index
      primary_ipv6                = network_interfaces.value.primary_ipv6
      private_ip_address          = network_interfaces.value.private_ip_address
      security_groups             = network_interfaces.value.security_groups
      subnet_id                   = network_interfaces.value.subnet_id
      delete_on_termination       = network_interfaces.value.delete_on_termination
    }

  }

  dynamic "metadata_options" {
    for_each = var.launch_template.metadata_options != null ? [var.launch_template.metadata_options] : []
    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_tokens                 = metadata_options.value.http_tokens
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      http_protocol_ipv6          = metadata_options.value.http_protocol_ipv6
      instance_metadata_tags      = metadata_options.value.instance_metadata_tags
    }
  }

  dynamic "placement" {
    for_each = var.launch_template.placement != null ? [var.launch_template.placement] : []
    content {
      availability_zone       = placement.value.availability_zone
      group_name              = placement.value.group_name
      host_id                 = placement.value.host_id
      host_resource_group_arn = placement.value.host_resource_group_arn
      spread_domain           = placement.value.spread_domain
      tenancy                 = placement.value.tenancy
      partition_number        = placement.value.partition_number
      affinity                = placement.value.affinity
    }
  }

  dynamic "private_dns_name_options" {
    for_each = var.launch_template.private_dns_name_options != null ? [var.launch_template.private_dns_name_options] : []
    content {
      enable_resource_name_dns_aaaa_record = private_dns_name_options.value.enable_resource_name_dns_aaaa_record
      enable_resource_name_dns_a_record    = private_dns_name_options.value.enable_resource_name_dns_a_record
      hostname_type                        = private_dns_name_options.value.hostname_type
    }
  }


  dynamic "tag_specifications" {
    for_each = var.launch_template.tag_specifications != null ? [var.launch_template.tag_specifications] : []
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  tags = var.tags
}


################################################################################
# Auto Scaling Group
################################################################################

resource "aws_autoscaling_group" "this" {
  name                      = var.asg.name != null ? var.asg.name : "ec2-auto-scaling-group"
  min_size                  = var.asg.min_size
  max_size                  = var.asg.max_size
  desired_capacity          = var.asg.desired_capacity != null ? var.asg.desired_capacity : var.asg.min_size
  desired_capacity_type     = var.asg.desired_capacity_type
  vpc_zone_identifier       = var.asg.vpc_zone_identifier
  availability_zones        = var.asg.availability_zones
  min_elb_capacity          = var.asg.min_elb_capacity
  wait_for_elb_capacity     = var.asg.wait_for_elb_capacity
  wait_for_capacity_timeout = var.asg.wait_for_capacity_timeout
  capacity_rebalance        = var.asg.capacity_rebalance
  context                   = var.asg.context

  placement_group                  = var.asg.placement_group
  health_check_type                = var.asg.health_check_type != null ? var.asg.health_check_type : "EC2"
  health_check_grace_period        = var.asg.health_check_grace_period != null ? var.asg.health_check_grace_period : 300
  protect_from_scale_in            = var.asg.protect_from_scale_in != null ? var.asg.protect_from_scale_in : false
  default_cooldown                 = var.asg.default_cooldown != null ? var.asg.default_cooldown : 300
  default_instance_warmup          = var.asg.default_instance_warmup != null ? var.asg.default_instance_warmup : 300
  force_delete                     = var.asg.force_delete != null ? var.asg.force_delete : false
  max_instance_lifetime            = var.asg.max_instance_lifetime != null ? var.asg.max_instance_lifetime : null
  metrics_granularity              = var.asg.metrics_granularity != null ? var.asg.metrics_granularity : "1Minute"
  enabled_metrics                  = var.asg.enabled_metrics
  termination_policies             = var.asg.termination_policies
  suspended_processes              = var.asg.suspended_processes
  service_linked_role_arn          = var.asg.service_linked_role_arn
  ignore_failed_scaling_activities = var.asg.instance_generations
  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  dynamic "availability_zone_distribution" {
    for_each = var.asg.availability_zone_distribution != null ? [1] : []
    content {
      capacity_distribution_strategy = availability_zone_distribution.value.capacity_distribution_strategy
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.asg.initial_lifecycle_hook != null ? var.asg.initial_lifecycle_hook : []
    content {
      name                    = initial_lifecycle_hook.value.name
      lifecycle_transition    = initial_lifecycle_hook.value.lifecycle_transition
      default_result          = lookup(initial_lifecycle_hook.value, "default_result", null)
      heartbeat_timeout       = lookup(initial_lifecycle_hook.value, "heartbeat_timeout", null)
      notification_metadata   = lookup(initial_lifecycle_hook.value, "notification_metadata", null)
      notification_target_arn = lookup(initial_lifecycle_hook.value, "notification_target_arn", null)
      role_arn                = lookup(initial_lifecycle_hook.value, "role_arn", null)
    }
  }

  dynamic "instance_maintenance_policy" {
    for_each = var.asg.instance_maintenance_policy != null ? [var.asg.instance_maintenance_policy] : []
    content {
      min_healthy_percentage = lookup(instance_maintenance_policy.value, "min_healthy_percentage", null)
      max_healthy_percentage = lookup(instance_maintenance_policy.value, "max_healthy_percentage", null)
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = var.asg.mixed_instances_policy != null ? [var.asg.mixed_instances_policy] : []
    content {
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.this.id
          version            = "$Latest"
        }

        dynamic "override" {
          for_each = lookup(mixed_instances_policy.value.launch_template, "override", [])

          content {
            dynamic "instance_requirements" {
              for_each = override.value.instance_requirements != null ? [override.value.instance_requirements] : []

              content {
                dynamic "accelerator_count" {
                  for_each = lookup(instance_requirements.value, "accelerator_count", null) != null ? [instance_requirements.value.accelerator_count] : []

                  content {
                    max = lookup(accelerator_count.value, "max", null)
                    min = lookup(accelerator_count.value, "min", null)
                  }
                }

                accelerator_manufacturers = lookup(instance_requirements.value, "accelerator_manufacturers", null)
                accelerator_names         = lookup(instance_requirements.value, "accelerator_names", null)

                dynamic "accelerator_total_memory_mib" {
                  for_each = lookup(instance_requirements.value, "accelerator_total_memory_mib", null) != null ? [instance_requirements.value.accelerator_total_memory_mib] : []

                  content {
                    max = lookup(accelerator_total_memory_mib.value, "max", null)
                    min = lookup(accelerator_total_memory_mib.value, "min", null)
                  }
                }

                accelerator_types      = lookup(instance_requirements.value, "accelerator_types", null)
                allowed_instance_types = lookup(instance_requirements.value, "allowed_instance_types", null)
                bare_metal             = lookup(instance_requirements.value, "bare_metal", null)

                dynamic "baseline_ebs_bandwidth_mbps" {
                  for_each = lookup(instance_requirements.value, "baseline_ebs_bandwidth_mbps", null) != null ? [instance_requirements.value.baseline_ebs_bandwidth_mbps] : []

                  content {
                    max = lookup(baseline_ebs_bandwidth_mbps.value, "max", null)
                    min = lookup(baseline_ebs_bandwidth_mbps.value, "min", null)
                  }
                }

                burstable_performance                                   = lookup(instance_requirements.value, "burstable_performance", null)
                cpu_manufacturers                                       = lookup(instance_requirements.value, "cpu_manufacturers", null)
                excluded_instance_types                                 = lookup(instance_requirements.value, "excluded_instance_types", null)
                instance_generations                                    = lookup(instance_requirements.value, "instance_generations", null)
                local_storage                                           = lookup(instance_requirements.value, "local_storage", null)
                local_storage_types                                     = lookup(instance_requirements.value, "local_storage_types", null)
                max_spot_price_as_percentage_of_optimal_on_demand_price = lookup(instance_requirements.value, "max_spot_price_as_percentage_of_optimal_on_demand_price", null)

                dynamic "memory_gib_per_vcpu" {
                  for_each = lookup(instance_requirements.value, "memory_gib_per_vcpu", null) != null ? [instance_requirements.value.memory_gib_per_vcpu] : []

                  content {
                    max = lookup(memory_gib_per_vcpu.value, "max", null)
                    min = lookup(memory_gib_per_vcpu.value, "min", null)
                  }
                }

                dynamic "memory_mib" {
                  for_each = lookup(instance_requirements.value, "memory_mib", null) != null ? [instance_requirements.value.memory_mib] : []

                  content {
                    max = lookup(memory_mib.value, "max", null)
                    min = lookup(memory_mib.value, "min", null)
                  }
                }

                dynamic "network_bandwidth_gbps" {
                  for_each = lookup(instance_requirements.value, "network_bandwidth_gbps", null) != null ? [instance_requirements.value.network_bandwidth_gbps] : []

                  content {
                    max = lookup(network_bandwidth_gbps.value, "max", null)
                    min = lookup(network_bandwidth_gbps.value, "min", null)
                  }
                }

                dynamic "network_interface_count" {
                  for_each = lookup(instance_requirements.value, "network_interface_count", null) != null ? [instance_requirements.value.network_interface_count] : []

                  content {
                    max = lookup(network_interface_count.value, "max", null)
                    min = lookup(network_interface_count.value, "min", null)
                  }
                }

                on_demand_max_price_percentage_over_lowest_price = lookup(instance_requirements.value, "on_demand_max_price_percentage_over_lowest_price", null)
                require_hibernate_support                        = lookup(instance_requirements.value, "require_hibernate_support", null)
                spot_max_price_percentage_over_lowest_price      = lookup(instance_requirements.value, "spot_max_price_percentage_over_lowest_price", null)

                dynamic "total_local_storage_gb" {
                  for_each = lookup(instance_requirements.value, "total_local_storage_gb", null) != null ? [instance_requirements.value.total_local_storage_gb] : []

                  content {
                    max = lookup(total_local_storage_gb.value, "max", null)
                    min = lookup(total_local_storage_gb.value, "min", null)
                  }
                }

                dynamic "vcpu_count" {
                  for_each = lookup(instance_requirements.value, "vcpu_count", null) != null ? [instance_requirements.value.vcpu_count] : []

                  content {
                    max = lookup(vcpu_count.value, "max", null)
                    min = lookup(vcpu_count.value, "min", null)
                  }
                }
              }
            }

            instance_type     = lookup(override.value, "instance_type", null)
            weighted_capacity = lookup(override.value, "weighted_capacity", null)

          }
        }
      }
      dynamic "instances_distribution" {
        for_each = mixed_instances_policy.value.instances_distribution != null ? [mixed_instances_policy.value.instances_distribution] : []
        content {
          on_demand_allocation_strategy            = lookup(instances_distribution.value, "on_demand_allocation_strategy", null)
          on_demand_base_capacity                  = lookup(instances_distribution.value, "on_demand_base_capacity", null)
          on_demand_percentage_above_base_capacity = lookup(instances_distribution.value, "on_demand_percentage_above_base_capacity", null)
          spot_allocation_strategy                 = lookup(instances_distribution.value, "spot_allocation_strategy", null)
          spot_instance_pools                      = lookup(instances_distribution.value, "spot_instance_pools", null)
          spot_max_price                           = lookup(instances_distribution.value, "spot_max_price", null)
        }
      }

    }
  }

  dynamic "warm_pool" {
    for_each = var.asg.warm_pool != null ? [var.asg.warm_pool] : []

    content {
      max_group_prepared_capacity = lookup(warm_pool.value, "max_group_prepared_capacity", null)
      min_size                    = lookup(warm_pool.value, "min_size", null)
      pool_state                  = lookup(warm_pool.value, "pool_state", null)

      dynamic "instance_reuse_policy" {
        for_each = lookup(warm_pool.value, "instance_reuse_policy", null) != null ? [warm_pool.value.instance_reuse_policy] : []

        content {
          reuse_on_scale_in = lookup(instance_reuse_policy.value, "reuse_on_scale_in", null)
        }
      }
    }
  }



  dynamic "instance_refresh" {
    for_each = var.asg.instance_refresh != null ? [var.asg.instance_refresh] : []
    content {
      strategy = lookup(instance_refresh.value[0], "strategy", null)

      dynamic "preferences" {
        for_each = try([instance_refresh.value[0].preferences], [])
        content {

          checkpoint_delay             = lookup(preferences.value, "checkpoint_delay", null)
          checkpoint_percentages       = lookup(preferences.value, "checkpoint_percentages", null)
          instance_warmup              = lookup(preferences.value, "instance_warmup", null)
          min_healthy_percentage       = lookup(preferences.value, "min_healthy_percentage", null)
          max_healthy_percentage       = lookup(preferences.value, "max_healthy_percentage", null)
          skip_matching                = lookup(preferences.value, "skip_matching", null)
          auto_rollback                = lookup(preferences.value, "auto_rollback", null)
          scale_in_protected_instances = lookup(preferences.value, "scale_in_protected_instances", null)
          standby_instances            = lookup(preferences.value, "standby_instances", null)
        }
      }

      triggers = lookup(instance_refresh.value[0], "triggers", null)
    }
  }

}

################################################################################
# Auto Scaling traffic source attachment
################################################################################

resource "aws_autoscaling_traffic_source_attachment" "this" {
  count = var.create_traffic_source_attachment && length(var.traffic_sources) > 0 ? length(var.traffic_sources) : 0

  autoscaling_group_name = aws_autoscaling_group.this.name

  traffic_source {
    identifier = lookup(var.traffic_sources[count.index], "identifier", null)
    type       = lookup(var.traffic_sources[count.index], "type", null)
  }
}
################################################################################
# Auto Scaling schedule
################################################################################

resource "aws_autoscaling_schedule" "this" {
  for_each = length(var.schedules) > 0 ? { for idx, sched in var.schedules : idx => sched } : {}

  scheduled_action_name  = lookup(each.value, "scheduled_action_name", null)
  autoscaling_group_name = aws_autoscaling_group.this.name
  desired_capacity       = lookup(each.value, "desired_capacity", null)
  min_size               = lookup(each.value, "min_size", null)
  max_size               = lookup(each.value, "max_size", null)
  start_time             = lookup(each.value, "start_time", null)
  end_time               = lookup(each.value, "end_time", null)
  recurrence             = lookup(each.value, "recurrence", null)
  time_zone              = lookup(each.value, "time_zone", null)
}

################################################################################
# Auto Scaling policy
################################################################################

resource "aws_autoscaling_policy" "this" {
  name                   = lookup(var.autoscaling_policy, "name", null)
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = lookup(var.autoscaling_policy, "policy_type", "TargetTrackingScaling")

  adjustment_type           = lookup(var.autoscaling_policy, "adjustment_type", null)
  cooldown                  = lookup(var.autoscaling_policy, "cooldown", null)
  estimated_instance_warmup = lookup(var.autoscaling_policy, "estimated_instance_warmup", null)
  scaling_adjustment        = lookup(var.autoscaling_policy, "scaling_adjustment", null)
  metric_aggregation_type   = lookup(var.autoscaling_policy, "metric_aggregation_type", null)
  min_adjustment_magnitude  = lookup(var.autoscaling_policy, "min_adjustment_magnitude", null)

  dynamic "step_adjustment" {
    for_each = (
    try(var.autoscaling_policy.step_adjustment, []) != null ? try(var.autoscaling_policy.step_adjustment, []) : [])
    content {
      scaling_adjustment          = lookup(step_adjustment.value, "scaling_adjustment", null)
      metric_interval_lower_bound = lookup(step_adjustment.value, "metric_interval_lower_bound", null)
      metric_interval_upper_bound = lookup(step_adjustment.value, "metric_interval_upper_bound", null)
    }
  }

  dynamic "target_tracking_configuration" {
    for_each = lookup(var.autoscaling_policy, "policy_type", "TargetTrackingScaling") == "TargetTrackingScaling" && var.autoscaling_policy.target_tracking_configuration != null ? [var.autoscaling_policy.target_tracking_configuration] : []
    content {
      target_value = lookup(target_tracking_configuration.value, "target_value", 70)
      predefined_metric_specification {
        predefined_metric_type = lookup(target_tracking_configuration.value.predefined_metric_specification, "predefined_metric_type", null)
        resource_label         = lookup(target_tracking_configuration.value.predefined_metric_specification, "resource_label", null)
      }
    }
  }

  dynamic "predictive_scaling_configuration" {
    for_each = lookup(var.autoscaling_policy, "policy_type", "TargetTrackingScaling") == "PredictiveScaling" && var.predictive_scaling_configuration != null ? [var.predictive_scaling_configuration] : []

    content {
      mode                         = lookup(predictive_scaling_configuration.value, "mode", null)
      scheduling_buffer_time       = lookup(predictive_scaling_configuration.value, "scheduling_buffer_time", null)
      max_capacity_breach_behavior = lookup(predictive_scaling_configuration.value, "max_capacity_breach_behavior", null)
      max_capacity_buffer          = lookup(predictive_scaling_configuration.value, "max_capacity_buffer", null)

      dynamic "metric_specification" {
        for_each = lookup(predictive_scaling_configuration.value, "metric_specification", [])

        content {
          target_value = lookup(metric_specification.value, "target_value", null)

          predefined_metric_pair_specification {
            predefined_metric_type = lookup(metric_specification.value.predefined_metric_pair_specification, "predefined_metric_type", null)
            resource_label         = lookup(metric_specification.value.predefined_metric_pair_specification, "resource_label", null)
          }

          predefined_load_metric_specification {
            predefined_metric_type = lookup(metric_specification.value.predefined_load_metric_specification, "predefined_metric_type", null)
            resource_label         = lookup(metric_specification.value.predefined_load_metric_specification, "resource_label", null)
          }

          predefined_scaling_metric_specification {
            predefined_metric_type = lookup(metric_specification.value.predefined_scaling_metric_specification, "predefined_metric_type", null)
            resource_label         = lookup(metric_specification.value.predefined_scaling_metric_specification, "resource_label", null)
          }

          customized_scaling_metric_specification {
            dynamic "metric_data_queries" {
              for_each = lookup(metric_specification.value.customized_scaling_metric_specification, "metric_data_queries", [])

              content {
                id          = lookup(metric_data_queries.value, "id", null)
                expression  = lookup(metric_data_queries.value, "expression", null)
                label       = lookup(metric_data_queries.value, "label", null)
                return_data = lookup(metric_data_queries.value, "return_data", null)

                dynamic "metric_stat" {
                  for_each = lookup(metric_data_queries.value, "metric_stat", []) != null ? [lookup(metric_data_queries.value, "metric_stat", {})] : []

                  content {
                    stat = lookup(metric_stat.value, "stat", null)
                    unit = lookup(metric_stat.value, "unit", null)

                    metric {
                      metric_name = lookup(metric_stat.value.metric, "metric_name", null)
                      namespace   = lookup(metric_stat.value.metric, "namespace", null)

                      dynamic "dimensions" {
                        for_each = lookup(metric_stat.value.metric, "dimensions", [])

                        content {
                          name  = lookup(dimensions.value, "name", null)
                          value = lookup(dimensions.value, "value", null)
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          customized_load_metric_specification {
            dynamic "metric_data_queries" {
              for_each = lookup(metric_specification.value.customized_load_metric_specification, "metric_data_queries", [])

              content {
                id          = lookup(metric_data_queries.value, "id", null)
                expression  = lookup(metric_data_queries.value, "expression", null)
                label       = lookup(metric_data_queries.value, "label", null)
                return_data = lookup(metric_data_queries.value, "return_data", null)

                dynamic "metric_stat" {
                  for_each = lookup(metric_data_queries.value, "metric_stat", []) != null ? [lookup(metric_data_queries.value, "metric_stat", {})] : []

                  content {
                    stat = lookup(metric_stat.value, "stat", null)
                    unit = lookup(metric_stat.value, "unit", null)

                    metric {
                      metric_name = lookup(metric_stat.value.metric, "metric_name", null)
                      namespace   = lookup(metric_stat.value.metric, "namespace", null)

                      dynamic "dimensions" {
                        for_each = lookup(metric_stat.value.metric, "dimensions", [])

                        content {
                          name  = lookup(dimensions.value, "name", null)
                          value = lookup(dimensions.value, "value", null)
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          customized_capacity_metric_specification {
            dynamic "metric_data_queries" {
              for_each = lookup(metric_specification.value.customized_capacity_metric_specification, "metric_data_queries", [])

              content {
                id          = lookup(metric_data_queries.value, "id", null)
                expression  = lookup(metric_data_queries.value, "expression", null)
                label       = lookup(metric_data_queries.value, "label", null)
                return_data = lookup(metric_data_queries.value, "return_data", null)

                dynamic "metric_stat" {
                  for_each = lookup(metric_data_queries.value, "metric_stat", []) != null ? [lookup(metric_data_queries.value, "metric_stat", {})] : []

                  content {
                    stat = lookup(metric_stat.value, "stat", null)
                    unit = lookup(metric_stat.value, "unit", null)

                    metric {
                      metric_name = lookup(metric_stat.value.metric, "metric_name", null)
                      namespace   = lookup(metric_stat.value.metric, "namespace", null)

                      dynamic "dimensions" {
                        for_each = lookup(metric_stat.value.metric, "dimensions", [])

                        content {
                          name  = lookup(dimensions.value, "name", null)
                          value = lookup(dimensions.value, "value", null)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}


################################################################################
# Auto Scaling notification
################################################################################

resource "aws_autoscaling_notification" "this" {
  count = var.autoscaling_notification_enabled ? 1 : 0

  group_names = [aws_autoscaling_group.this.name]

  notifications = var.autoscaling_notification_types

  topic_arn = var.autoscaling_sns_topic_arn
}


################################################################################
# Auto Scaling attachment
################################################################################

resource "aws_autoscaling_attachment" "this" {
  for_each = var.create_autoscaling_attachment ? var.autoscaling_attachments : {}

  autoscaling_group_name = each.value.autoscaling_group_name
  lb_target_group_arn    = lookup(each.value, "lb_target_group_arn", null)
  elb                    = lookup(each.value, "elb", null)
}

################################################################################
# instance-profile-role
################################################################################
resource "aws_iam_role" "this" {
  name = "asg-instance-profile-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = var.instance_profile_name
  role = aws_iam_role.this.name
}
