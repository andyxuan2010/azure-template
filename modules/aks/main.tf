data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  count = local.resource_group_lookup_required ? 1 : 0

  name = local.resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  count = local.private_dns_zone_lookup_required ? 1 : 0

  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}

resource "random_string" "suffix" {
  count = trimspace(var.name) == "" && var.use_random_suffix ? 1 : 0

  length  = 6
  upper   = false
  special = false
}

resource "azurerm_kubernetes_cluster" "this" {
  name                                = local.aks_name
  location                            = local.location
  resource_group_name                 = local.resource_group_name
  node_resource_group                 = trimspace(var.node_resource_group_name) != "" ? trimspace(var.node_resource_group_name) : null
  dns_prefix                          = trimspace(var.dns_prefix_private_cluster) == "" ? local.dns_prefix : null
  dns_prefix_private_cluster          = trimspace(var.dns_prefix_private_cluster) != "" ? trimspace(var.dns_prefix_private_cluster) : null
  kubernetes_version                  = var.kubernetes_version
  sku_tier                            = var.sku_tier
  support_plan                        = var.support_plan
  cost_analysis_enabled               = var.cost_analysis_enabled
  automatic_upgrade_channel           = var.automatic_upgrade_channel
  node_os_upgrade_channel             = var.node_os_upgrade_channel
  private_cluster_enabled             = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_enabled ? var.private_cluster_public_fqdn_enabled : false
  private_dns_zone_id                 = local.private_dns_zone_id_resolved
  role_based_access_control_enabled   = var.role_based_access_control_enabled
  local_account_disabled              = var.local_account_disabled
  run_command_enabled                 = var.run_command_enabled
  oidc_issuer_enabled                 = var.oidc_issuer_enabled
  workload_identity_enabled           = var.workload_identity_enabled
  azure_policy_enabled                = var.azure_policy_enabled
  image_cleaner_enabled               = var.image_cleaner_enabled
  image_cleaner_interval_hours        = var.image_cleaner_enabled ? var.image_cleaner_interval_hours : null
  tags                                = local.effective_tags

  default_node_pool {
    name                          = var.default_node_pool.name
    vm_size                       = var.default_node_pool.vm_size
    node_count                    = local.default_node_pool_auto_scaling_enabled ? null : var.default_node_pool.node_count
    auto_scaling_enabled          = local.default_node_pool_auto_scaling_enabled
    min_count                     = local.default_node_pool_auto_scaling_enabled ? var.default_node_pool.min_count : null
    max_count                     = local.default_node_pool_auto_scaling_enabled ? var.default_node_pool.max_count : null
    zones                         = length(var.default_node_pool.zones) > 0 ? var.default_node_pool.zones : null
    os_disk_size_gb               = var.default_node_pool.os_disk_size_gb
    os_disk_type                  = var.default_node_pool.os_disk_type
    os_sku                        = var.default_node_pool.os_sku
    max_pods                      = try(var.default_node_pool.max_pods, null)
    vnet_subnet_id                = try(trimspace(var.default_node_pool.vnet_subnet_id), "") != "" ? var.default_node_pool.vnet_subnet_id : null
    pod_subnet_id                 = try(trimspace(var.default_node_pool.pod_subnet_id), "") != "" ? var.default_node_pool.pod_subnet_id : null
    only_critical_addons_enabled  = var.default_node_pool.only_critical_addons_enabled
    orchestrator_version          = try(var.default_node_pool.orchestrator_version, null)
    type                          = var.default_node_pool.type
    temporary_name_for_rotation   = try(var.default_node_pool.temporary_name_for_rotation, null)
    host_encryption_enabled       = try(var.default_node_pool.host_encryption_enabled, false)
    ultra_ssd_enabled             = try(var.default_node_pool.ultra_ssd_enabled, false)
    fips_enabled                  = try(var.default_node_pool.fips_enabled, false)
    kubelet_disk_type             = try(var.default_node_pool.kubelet_disk_type, null)
    node_labels                   = length(try(var.default_node_pool.node_labels, {})) > 0 ? var.default_node_pool.node_labels : null
    node_public_ip_enabled        = try(var.default_node_pool.node_public_ip_enabled, false)
    node_public_ip_prefix_id      = try(var.default_node_pool.node_public_ip_prefix_id, null)
    capacity_reservation_group_id = try(var.default_node_pool.capacity_reservation_group_id, null)
    host_group_id                 = try(var.default_node_pool.host_group_id, null)
    proximity_placement_group_id  = try(var.default_node_pool.proximity_placement_group_id, null)
    scale_down_mode               = try(var.default_node_pool.scale_down_mode, null)
    snapshot_id                   = try(var.default_node_pool.snapshot_id, null)
    tags                          = merge(local.effective_tags, try(var.default_node_pool.tags, {}))
    workload_runtime              = try(var.default_node_pool.workload_runtime, null)

    dynamic "kubelet_config" {
      for_each = try(var.default_node_pool.kubelet_config, null) == null ? [] : [var.default_node_pool.kubelet_config]

      content {
        allowed_unsafe_sysctls    = try(kubelet_config.value.allowed_unsafe_sysctls, null)
        container_log_max_files   = try(kubelet_config.value.container_log_max_files, null)
        container_log_max_line    = try(kubelet_config.value.container_log_max_line, null)
        container_log_max_size_mb = try(kubelet_config.value.container_log_max_size_mb, null)
        cpu_cfs_quota_enabled     = try(kubelet_config.value.cpu_cfs_quota_enabled, null)
        cpu_cfs_quota_period      = try(kubelet_config.value.cpu_cfs_quota_period, null)
        cpu_manager_policy        = try(kubelet_config.value.cpu_manager_policy, null)
        image_gc_high_threshold   = try(kubelet_config.value.image_gc_high_threshold, null)
        image_gc_low_threshold    = try(kubelet_config.value.image_gc_low_threshold, null)
        pod_max_pid               = try(kubelet_config.value.pod_max_pid, null)
        topology_manager_policy   = try(kubelet_config.value.topology_manager_policy, null)
      }
    }

    dynamic "linux_os_config" {
      for_each = try(var.default_node_pool.linux_os_config, null) == null ? [] : [var.default_node_pool.linux_os_config]

      content {
        swap_file_size_mb             = try(linux_os_config.value.swap_file_size_mb, null)
        transparent_huge_page         = try(linux_os_config.value.transparent_huge_page, null)
        transparent_huge_page_defrag  = try(linux_os_config.value.transparent_huge_page_defrag, null)
        transparent_huge_page_enabled = try(linux_os_config.value.transparent_huge_page_enabled, null)
      }
    }

    dynamic "node_network_profile" {
      for_each = try(var.default_node_pool.node_network_profile, null) == null ? [] : [var.default_node_pool.node_network_profile]

      content {
        application_security_group_ids = try(node_network_profile.value.application_security_group_ids, null)
        node_public_ip_tags            = try(node_network_profile.value.node_public_ip_tags, null)

        dynamic "allowed_host_ports" {
          for_each = try(node_network_profile.value.allowed_host_ports, [])

          content {
            port_end   = try(allowed_host_ports.value.port_end, null)
            port_start = try(allowed_host_ports.value.port_start, null)
            protocol   = try(allowed_host_ports.value.protocol, null)
          }
        }
      }
    }

    dynamic "upgrade_settings" {
      for_each = try(var.default_node_pool.upgrade_settings.max_surge, null) == null ? [] : [var.default_node_pool.upgrade_settings]

      content {
        max_surge                     = upgrade_settings.value.max_surge
        drain_timeout_in_minutes      = try(upgrade_settings.value.drain_timeout_in_minutes, null)
        node_soak_duration_in_minutes = try(upgrade_settings.value.node_soak_duration_in_minutes, null)
        undrainable_node_behavior     = try(upgrade_settings.value.undrainable_node_behavior, null)
      }
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.api_server_access_profile != null || (!var.private_cluster_enabled && length(var.api_server_authorized_ip_ranges) > 0) ? [1] : []

    content {
      authorized_ip_ranges                = var.api_server_access_profile != null ? try(var.api_server_access_profile.authorized_ip_ranges, null) : var.api_server_authorized_ip_ranges
      subnet_id                           = var.api_server_access_profile != null ? try(var.api_server_access_profile.subnet_id, null) : null
      virtual_network_integration_enabled = var.api_server_access_profile != null ? try(var.api_server_access_profile.virtual_network_integration_enabled, false) : null
    }
  }

  identity {
    type         = local.identity_type
    identity_ids = length(local.identity_ids) > 0 ? local.identity_ids : null
  }

  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity == null ? [] : [var.kubelet_identity]

    content {
      client_id                 = kubelet_identity.value.client_id
      object_id                 = kubelet_identity.value.object_id
      user_assigned_identity_id = kubelet_identity.value.user_assigned_identity_id
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control_enabled ? [1] : []

    content {
      azure_rbac_enabled     = var.azure_rbac_enabled
      admin_group_object_ids = local.admin_group_object_ids
      tenant_id              = trimspace(var.tenant_id) != "" ? trimspace(var.tenant_id) : null
    }
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile == null ? [] : [var.auto_scaler_profile]

    content {
      balance_similar_node_groups                   = try(auto_scaler_profile.value.balance_similar_node_groups, null)
      daemonset_eviction_for_empty_nodes_enabled    = try(auto_scaler_profile.value.daemonset_eviction_for_empty_nodes_enabled, null)
      daemonset_eviction_for_occupied_nodes_enabled = try(auto_scaler_profile.value.daemonset_eviction_for_occupied_nodes_enabled, null)
      empty_bulk_delete_max                         = try(auto_scaler_profile.value.empty_bulk_delete_max, null)
      expander                                      = try(auto_scaler_profile.value.expander, null)
      ignore_daemonsets_utilization_enabled         = try(auto_scaler_profile.value.ignore_daemonsets_utilization_enabled, null)
      max_graceful_termination_sec                  = try(auto_scaler_profile.value.max_graceful_termination_sec, null)
      max_node_provisioning_time                    = try(auto_scaler_profile.value.max_node_provisioning_time, null)
      max_unready_nodes                             = try(auto_scaler_profile.value.max_unready_nodes, null)
      max_unready_percentage                        = try(auto_scaler_profile.value.max_unready_percentage, null)
      new_pod_scale_up_delay                        = try(auto_scaler_profile.value.new_pod_scale_up_delay, null)
      scale_down_delay_after_add                    = try(auto_scaler_profile.value.scale_down_delay_after_add, null)
      scale_down_delay_after_delete                 = try(auto_scaler_profile.value.scale_down_delay_after_delete, null)
      scale_down_delay_after_failure                = try(auto_scaler_profile.value.scale_down_delay_after_failure, null)
      scale_down_unneeded                           = try(auto_scaler_profile.value.scale_down_unneeded, null)
      scale_down_unready                            = try(auto_scaler_profile.value.scale_down_unready, null)
      scale_down_utilization_threshold              = try(auto_scaler_profile.value.scale_down_utilization_threshold, null)
      scan_interval                                 = try(auto_scaler_profile.value.scan_interval, null)
      skip_nodes_with_local_storage                 = try(auto_scaler_profile.value.skip_nodes_with_local_storage, null)
      skip_nodes_with_system_pods                   = try(auto_scaler_profile.value.skip_nodes_with_system_pods, null)
    }
  }

  network_profile {
    network_plugin      = var.network_profile.network_plugin
    network_plugin_mode = try(var.network_profile.network_plugin_mode, null)
    network_policy      = try(var.network_profile.network_policy, null)
    network_data_plane  = try(var.network_profile.network_data_plane, null)
    network_mode        = try(var.network_profile.network_mode, null)
    service_cidr        = try(var.network_profile.service_cidr, null)
    service_cidrs       = try(var.network_profile.service_cidrs, null)
    dns_service_ip      = try(var.network_profile.dns_service_ip, null)
    pod_cidr            = try(var.network_profile.pod_cidr, null)
    pod_cidrs           = try(var.network_profile.pod_cidrs, null)
    ip_versions         = try(var.network_profile.ip_versions, null)
    load_balancer_sku   = lower(var.network_profile.load_balancer_sku)
    outbound_type       = var.network_profile.outbound_type

    dynamic "advanced_networking" {
      for_each = try(var.network_profile.advanced_networking, null) == null ? [] : [var.network_profile.advanced_networking]

      content {
        observability_enabled = try(advanced_networking.value.observability_enabled, null)
        security_enabled      = try(advanced_networking.value.security_enabled, null)
      }
    }

    dynamic "load_balancer_profile" {
      for_each = try(var.network_profile.load_balancer_profile, null) == null ? [] : [var.network_profile.load_balancer_profile]

      content {
        backend_pool_type           = try(load_balancer_profile.value.backend_pool_type, null)
        idle_timeout_in_minutes     = try(load_balancer_profile.value.idle_timeout_in_minutes, null)
        managed_outbound_ip_count   = try(load_balancer_profile.value.managed_outbound_ip_count, null)
        managed_outbound_ipv6_count = try(load_balancer_profile.value.managed_outbound_ipv6_count, null)
        outbound_ip_address_ids     = try(load_balancer_profile.value.outbound_ip_address_ids, null)
        outbound_ip_prefix_ids      = try(load_balancer_profile.value.outbound_ip_prefix_ids, null)
        outbound_ports_allocated    = try(load_balancer_profile.value.outbound_ports_allocated, null)
      }
    }

    dynamic "nat_gateway_profile" {
      for_each = try(var.network_profile.nat_gateway_profile, null) == null ? [] : [var.network_profile.nat_gateway_profile]

      content {
        idle_timeout_in_minutes   = try(nat_gateway_profile.value.idle_timeout_in_minutes, null)
        managed_outbound_ip_count = try(nat_gateway_profile.value.managed_outbound_ip_count, null)
      }
    }
  }

  dynamic "oms_agent" {
    for_each = local.oms_agent_enabled ? [1] : []

    content {
      log_analytics_workspace_id      = local.oms_agent_workspace_id
      msi_auth_for_monitoring_enabled = var.oms_agent_msi_auth_for_monitoring_enabled
    }
  }

  dynamic "microsoft_defender" {
    for_each = local.defender_enabled ? [1] : []

    content {
      log_analytics_workspace_id = local.defender_workspace_id
    }
  }

  dynamic "monitor_metrics" {
    for_each = local.monitor_metrics_enabled ? [local.monitor_metrics_effective] : []

    content {
      annotations_allowed = try(monitor_metrics.value.annotations_allowed, null)
      labels_allowed      = try(monitor_metrics.value.labels_allowed, null)
    }
  }

  dynamic "storage_profile" {
    for_each = var.storage_profile == null ? [] : [var.storage_profile]

    content {
      blob_driver_enabled         = try(storage_profile.value.blob_driver_enabled, false)
      disk_driver_enabled         = try(storage_profile.value.disk_driver_enabled, true)
      file_driver_enabled         = try(storage_profile.value.file_driver_enabled, true)
      snapshot_controller_enabled = try(storage_profile.value.snapshot_controller_enabled, true)
    }
  }

  dynamic "workload_autoscaler_profile" {
    for_each = var.workload_autoscaler_profile == null ? [] : [var.workload_autoscaler_profile]

    content {
      keda_enabled                    = try(workload_autoscaler_profile.value.keda_enabled, false)
      vertical_pod_autoscaler_enabled = try(workload_autoscaler_profile.value.vertical_pod_autoscaler_enabled, false)
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? [1] : []

    content {
      secret_rotation_enabled  = var.key_vault_secrets_provider_secret_rotation_enabled
      secret_rotation_interval = var.key_vault_secrets_provider_secret_rotation_interval
    }
  }

  dynamic "key_management_service" {
    for_each = var.key_management_service == null ? [] : [var.key_management_service]

    content {
      key_vault_key_id         = key_management_service.value.key_vault_key_id
      key_vault_network_access = try(key_management_service.value.key_vault_network_access, null)
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway == null ? [] : [var.ingress_application_gateway]

    content {
      gateway_id   = try(ingress_application_gateway.value.gateway_id, null)
      gateway_name = try(ingress_application_gateway.value.gateway_name, null)
      subnet_cidr  = try(ingress_application_gateway.value.subnet_cidr, null)
      subnet_id    = try(ingress_application_gateway.value.subnet_id, null)
    }
  }

  dynamic "web_app_routing" {
    for_each = var.web_app_routing == null ? [] : [var.web_app_routing]

    content {
      default_nginx_controller = try(web_app_routing.value.default_nginx_controller, null)
      dns_zone_ids             = web_app_routing.value.dns_zone_ids
    }
  }

  dynamic "http_proxy_config" {
    for_each = var.http_proxy_config == null ? [] : [var.http_proxy_config]

    content {
      http_proxy  = try(http_proxy_config.value.http_proxy, null)
      https_proxy = try(http_proxy_config.value.https_proxy, null)
      no_proxy    = try(http_proxy_config.value.no_proxy, null)
      trusted_ca  = try(http_proxy_config.value.trusted_ca, null)
    }
  }

  dynamic "linux_profile" {
    for_each = var.linux_profile == null ? [] : [var.linux_profile]

    content {
      admin_username = linux_profile.value.admin_username

      ssh_key {
        key_data = linux_profile.value.ssh_key.key_data
      }
    }
  }

  dynamic "windows_profile" {
    for_each = var.windows_profile == null ? [] : [var.windows_profile]

    content {
      admin_password = windows_profile.value.admin_password
      admin_username = windows_profile.value.admin_username
      license        = try(windows_profile.value.license, null)
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window == null ? [] : [var.maintenance_window]

    content {
      dynamic "allowed" {
        for_each = try(maintenance_window.value.allowed, [])

        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }

      dynamic "not_allowed" {
        for_each = try(maintenance_window.value.not_allowed, [])

        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade == null ? [] : [var.maintenance_window_auto_upgrade]

    content {
      day_of_month = try(maintenance_window_auto_upgrade.value.day_of_month, null)
      day_of_week  = try(maintenance_window_auto_upgrade.value.day_of_week, null)
      duration     = maintenance_window_auto_upgrade.value.duration
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      start_date   = try(maintenance_window_auto_upgrade.value.start_date, null)
      start_time   = try(maintenance_window_auto_upgrade.value.start_time, null)
      utc_offset   = try(maintenance_window_auto_upgrade.value.utc_offset, null)
      week_index   = try(maintenance_window_auto_upgrade.value.week_index, null)

      dynamic "not_allowed" {
        for_each = try(maintenance_window_auto_upgrade.value.not_allowed, [])

        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os == null ? [] : [var.maintenance_window_node_os]

    content {
      day_of_month = try(maintenance_window_node_os.value.day_of_month, null)
      day_of_week  = try(maintenance_window_node_os.value.day_of_week, null)
      duration     = maintenance_window_node_os.value.duration
      frequency    = maintenance_window_node_os.value.frequency
      interval     = maintenance_window_node_os.value.interval
      start_date   = try(maintenance_window_node_os.value.start_date, null)
      start_time   = try(maintenance_window_node_os.value.start_time, null)
      utc_offset   = try(maintenance_window_node_os.value.utc_offset, null)
      week_index   = try(maintenance_window_node_os.value.week_index, null)

      dynamic "not_allowed" {
        for_each = try(maintenance_window_node_os.value.not_allowed, [])

        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  dynamic "upgrade_override" {
    for_each = var.upgrade_override == null ? [] : [var.upgrade_override]

    content {
      effective_until       = try(upgrade_override.value.effective_until, null)
      force_upgrade_enabled = upgrade_override.value.force_upgrade_enabled
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.node_pools

  kubernetes_cluster_id         = azurerm_kubernetes_cluster.this.id
  name                          = try(trimspace(each.value.name), "") != "" ? trimspace(each.value.name) : each.key
  vm_size                       = each.value.vm_size
  mode                          = try(each.value.mode, "User")
  os_type                       = try(each.value.os_type, "Linux")
  os_sku                        = try(each.value.os_sku, null)
  node_count                    = try(each.value.auto_scaling_enabled, true) ? null : try(each.value.node_count, 1)
  auto_scaling_enabled          = try(each.value.auto_scaling_enabled, true)
  min_count                     = try(each.value.auto_scaling_enabled, true) ? try(each.value.min_count, 1) : null
  max_count                     = try(each.value.auto_scaling_enabled, true) ? try(each.value.max_count, 3) : null
  zones                         = length(try(each.value.zones, [])) > 0 ? each.value.zones : null
  orchestrator_version          = try(each.value.orchestrator_version, null)
  max_pods                      = try(each.value.max_pods, null)
  vnet_subnet_id                = try(trimspace(each.value.vnet_subnet_id), "") != "" ? each.value.vnet_subnet_id : null
  pod_subnet_id                 = try(trimspace(each.value.pod_subnet_id), "") != "" ? each.value.pod_subnet_id : null
  os_disk_size_gb               = try(each.value.os_disk_size_gb, null)
  os_disk_type                  = try(each.value.os_disk_type, null)
  kubelet_disk_type             = try(each.value.kubelet_disk_type, null)
  node_labels                   = length(try(each.value.node_labels, {})) > 0 ? each.value.node_labels : null
  node_taints                   = length(try(each.value.node_taints, [])) > 0 ? each.value.node_taints : null
  node_public_ip_enabled        = try(each.value.node_public_ip_enabled, false)
  node_public_ip_prefix_id      = try(each.value.node_public_ip_prefix_id, null)
  priority                      = try(each.value.priority, null)
  eviction_policy               = try(each.value.eviction_policy, null)
  spot_max_price                = try(each.value.spot_max_price, null)
  scale_down_mode               = try(each.value.scale_down_mode, null)
  temporary_name_for_rotation   = try(each.value.temporary_name_for_rotation, null)
  ultra_ssd_enabled             = try(each.value.ultra_ssd_enabled, false)
  host_encryption_enabled       = try(each.value.host_encryption_enabled, false)
  fips_enabled                  = try(each.value.fips_enabled, false)
  capacity_reservation_group_id = try(each.value.capacity_reservation_group_id, null)
  host_group_id                 = try(each.value.host_group_id, null)
  proximity_placement_group_id  = try(each.value.proximity_placement_group_id, null)
  snapshot_id                   = try(each.value.snapshot_id, null)
  workload_runtime              = try(each.value.workload_runtime, null)
  gpu_driver                    = try(each.value.gpu_driver, null)
  gpu_instance                  = try(each.value.gpu_instance, null)
  tags                          = merge(local.effective_tags, try(each.value.tags, {}))

  dynamic "kubelet_config" {
    for_each = try(each.value.kubelet_config, null) == null ? [] : [each.value.kubelet_config]

    content {
      allowed_unsafe_sysctls    = try(kubelet_config.value.allowed_unsafe_sysctls, null)
      container_log_max_files   = try(kubelet_config.value.container_log_max_files, null)
      container_log_max_line    = try(kubelet_config.value.container_log_max_line, null)
      container_log_max_size_mb = try(kubelet_config.value.container_log_max_size_mb, null)
      cpu_cfs_quota_enabled     = try(kubelet_config.value.cpu_cfs_quota_enabled, null)
      cpu_cfs_quota_period      = try(kubelet_config.value.cpu_cfs_quota_period, null)
      cpu_manager_policy        = try(kubelet_config.value.cpu_manager_policy, null)
      image_gc_high_threshold   = try(kubelet_config.value.image_gc_high_threshold, null)
      image_gc_low_threshold    = try(kubelet_config.value.image_gc_low_threshold, null)
      pod_max_pid               = try(kubelet_config.value.pod_max_pid, null)
      topology_manager_policy   = try(kubelet_config.value.topology_manager_policy, null)
    }
  }

  dynamic "linux_os_config" {
    for_each = try(each.value.linux_os_config, null) == null ? [] : [each.value.linux_os_config]

    content {
      swap_file_size_mb             = try(linux_os_config.value.swap_file_size_mb, null)
      transparent_huge_page         = try(linux_os_config.value.transparent_huge_page, null)
      transparent_huge_page_defrag  = try(linux_os_config.value.transparent_huge_page_defrag, null)
      transparent_huge_page_enabled = try(linux_os_config.value.transparent_huge_page_enabled, null)
    }
  }

  dynamic "node_network_profile" {
    for_each = try(each.value.node_network_profile, null) == null ? [] : [each.value.node_network_profile]

    content {
      application_security_group_ids = try(node_network_profile.value.application_security_group_ids, null)
      node_public_ip_tags            = try(node_network_profile.value.node_public_ip_tags, null)

      dynamic "allowed_host_ports" {
        for_each = try(node_network_profile.value.allowed_host_ports, [])

        content {
          port_end   = try(allowed_host_ports.value.port_end, null)
          port_start = try(allowed_host_ports.value.port_start, null)
          protocol   = try(allowed_host_ports.value.protocol, null)
        }
      }
    }
  }

  dynamic "upgrade_settings" {
    for_each = try(each.value.upgrade_settings, null) == null ? [] : [each.value.upgrade_settings]

    content {
      drain_timeout_in_minutes      = try(upgrade_settings.value.drain_timeout_in_minutes, null)
      max_surge                     = try(upgrade_settings.value.max_surge, null)
      max_unavailable               = try(upgrade_settings.value.max_unavailable, null)
      node_soak_duration_in_minutes = try(upgrade_settings.value.node_soak_duration_in_minutes, null)
      undrainable_node_behavior     = try(upgrade_settings.value.undrainable_node_behavior, null)
    }
  }

  dynamic "windows_profile" {
    for_each = try(each.value.windows_profile, null) == null ? [] : [each.value.windows_profile]

    content {
      outbound_nat_enabled = try(windows_profile.value.outbound_nat_enabled, null)
    }
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.diagnostics_enabled ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id     = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_workspace_id : null
  log_analytics_destination_type = var.log_analytics_destination_type
  storage_account_id             = trimspace(var.diagnostic_storage_account_id) != "" ? var.diagnostic_storage_account_id : null
  eventhub_authorization_rule_id = trimspace(var.diagnostic_eventhub_authorization_rule_id) != "" ? var.diagnostic_eventhub_authorization_rule_id : null
  eventhub_name                  = var.diagnostic_eventhub_name

  dynamic "enabled_log" {
    for_each = local.diagnostic_log_categories_effective

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = local.diagnostic_log_category_groups_effective

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.diagnostic_metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = var.app_admin_role_definition_name
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = var.app_user_role_definition_name
  principal_id         = each.value
}

resource "azurerm_role_assignment" "terraform_execution_identity_cluster_access" {
  count = var.terraform_execution_aks_role != "" ? 1 : 0

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = var.terraform_execution_aks_role
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_kubernetes_cluster.this.id
  principal_id                           = each.value.principal_id
  principal_type                         = try(each.value.principal_type, null)
  role_definition_id                     = try(each.value.role_definition_id, null)
  role_definition_name                   = try(each.value.role_definition_name, null)
  name                                   = try(each.value.name, null)
  description                            = try(each.value.description, null)
  condition                              = try(each.value.condition, null)
  condition_version                      = try(each.value.condition_version, null)
  delegated_managed_identity_resource_id = try(each.value.delegated_managed_identity_resource_id, null)
  skip_service_principal_aad_check       = try(each.value.skip_service_principal_aad_check, false)
}
