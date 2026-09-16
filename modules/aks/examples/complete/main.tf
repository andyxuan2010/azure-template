terraform {
  required_version = ">= 1.6"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "aks" {
  source = "../.."

  resource_group_name       = var.resource_group_name
  location                  = var.location
  name                      = var.cluster_name
  app_env                   = "prod"
  sku_tier                  = "Standard"
  private_dns_zone_id       = "System"
  automatic_upgrade_channel = "stable"
  node_os_upgrade_channel   = "NodeImage"

  default_node_pool = {
    name                        = "system"
    vm_size                     = var.system_node_vm_size
    auto_scaling_enabled        = true
    min_count                   = 3
    max_count                   = 6
    zones                       = ["1", "2", "3"]
    os_sku                      = "AzureLinux"
    vnet_subnet_id              = var.subnet_id
    temporary_name_for_rotation = "sysrot"
    upgrade_settings = {
      max_surge = "33%"
    }
  }

  node_pools = {
    workload = {
      name                 = "workload"
      vm_size              = var.workload_node_vm_size
      auto_scaling_enabled = true
      min_count            = 1
      max_count            = 5
      zones                = ["1", "2", "3"]
      vnet_subnet_id       = var.subnet_id
      node_labels = {
        workload = "general"
      }
      upgrade_settings = {
        max_surge = "33%"
      }
    }
  }

  network_profile = {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    service_cidr        = "10.10.0.0/16"
    dns_service_ip      = "10.10.0.10"
    pod_cidr            = "10.244.0.0/16"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
    advanced_networking = {
      observability_enabled = true
      security_enabled      = true
    }
  }

  auto_scaler_profile = {
    balance_similar_node_groups = true
    expander                    = "least-waste"
    scan_interval               = "10s"
  }

  key_vault_secrets_provider_enabled                  = true
  key_vault_secrets_provider_secret_rotation_enabled  = true
  key_vault_secrets_provider_secret_rotation_interval = "2m"

  oms_agent_enabled          = true
  microsoft_defender_enabled = true
  monitor_metrics_enabled    = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enable_diagnostics             = true
  log_analytics_destination_type = "Dedicated"
  diagnostic_log_categories      = ["AllLogs"]
  diagnostic_metric_categories   = ["AllMetrics"]

  maintenance_window_auto_upgrade = {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "02:00"
    utc_offset  = "+00:00"
  }

  maintenance_window_node_os = {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "06:00"
    utc_offset  = "+00:00"
  }

  app_admin_group = var.admin_group_object_ids
  app_user_group  = var.user_group_object_ids

  tags = {
    Owner          = "Platform"
    DataClass      = "Internal"
    BusinessImpact = "High"
  }
}
