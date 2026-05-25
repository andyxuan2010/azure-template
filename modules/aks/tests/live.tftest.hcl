mock_provider "azurerm" {}

mock_provider "azuread" {}

variables {
  resource_group_name = "rg-ba-cc-prd-shared-management"
  location            = "canadacentral"
  name                = "aks-iactest-dev-001"
  app_env             = "dev"

  default_node_pool = {
    name                   = "system"
    vm_size                = "Standard_D4s_v5"
    node_count             = 1
    os_disk_size_gb        = 128
    os_disk_type           = "Managed"
    os_sku                 = "Ubuntu"
    vnet_subnet_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-aks"
    node_public_ip_enabled = false
  }

  app_admin_group = []
  app_user_group  = []

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_private_secure_defaults" {
  command = plan

  assert {
    condition     = output.name == "aks-iactest-dev-001"
    error_message = "AKS cluster name was not propagated."
  }

  assert {
    condition     = output.private_cluster_enabled == true && output.azure_rbac_enabled == true && output.local_account_disabled == true
    error_message = "Secure AKS defaults should enable private API, Azure RBAC, and disable local accounts."
  }

  assert {
    condition     = output.tags.Environment == "Development" && !contains(keys(output.tags), "ManagedBy") && !contains(keys(output.tags), "module") && !contains(keys(output.tags), "name") && !contains(keys(output.tags), "app_env")
    error_message = "Effective tags did not include standardized AKS tags."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-ba-cc-prd-shared-management"
    location                    = "canadacentral"
    name                        = ""
    name_prefix                 = "aks"
    workload_name               = "platform"
    app_env                     = "poc"
    include_environment_in_name = true
    location_code               = "cc"
    instance                    = "001"
    use_random_suffix           = false
    app_admin_group             = []
    app_user_group              = []
  }

  assert {
    condition     = output.name == "aks-platform-poc-cc-001"
    error_message = "Generated AKS name did not match the expected naming convention."
  }

  assert {
    condition     = output.location_code == "cc"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_platform_features_node_pools_and_diagnostics" {
  command = plan

  variables {
    resource_group_name       = "rg-ba-cc-prd-shared-management"
    location                  = "canadacentral"
    name                      = "aks-iactest-prod-001"
    app_env                   = "prod"
    sku_tier                  = "Standard"
    cost_analysis_enabled     = true
    support_plan              = "KubernetesOfficial"
    private_dns_zone_id       = "System"
    automatic_upgrade_channel = "stable"
    node_os_upgrade_channel   = "NodeImage"

    identity_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-aks"
    ]

    default_node_pool = {
      name                        = "system"
      vm_size                     = "Standard_D4s_v5"
      auto_scaling_enabled        = true
      min_count                   = 3
      max_count                   = 6
      zones                       = ["1", "2", "3"]
      os_sku                      = "AzureLinux"
      os_disk_type                = "Managed"
      vnet_subnet_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-aks"
      temporary_name_for_rotation = "sysrot"
      upgrade_settings = {
        max_surge = "33%"
      }
    }

    node_pools = {
      user = {
        name                 = "user"
        vm_size              = "Standard_D4s_v5"
        auto_scaling_enabled = true
        min_count            = 1
        max_count            = 3
        zones                = ["1", "2", "3"]
        vnet_subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-aks"
        node_labels = {
          workload = "general"
        }
        upgrade_settings = {
          max_surge = "1"
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

    oms_agent_enabled              = true
    microsoft_defender_enabled     = true
    monitor_metrics_enabled        = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    enable_diagnostics             = true
    diagnostic_log_categories      = ["AllLogs"]
    diagnostic_metric_categories   = ["AllMetrics"]

    app_admin_group = ["11111111-1111-1111-1111-111111111111"]
    app_user_group  = ["22222222-2222-2222-2222-222222222222"]
    role_assignments = {
      viewer = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        principal_type       = "Group"
        role_definition_name = "Azure Kubernetes Service RBAC Viewer"
      }
    }
  }

  assert {
    condition     = output.identity_type == "UserAssigned" && output.oms_agent_enabled == true && output.microsoft_defender_enabled == true
    error_message = "Platform feature plan should enable user-assigned identity, OMS agent, and Defender."
  }

  assert {
    condition     = length(output.node_pool_names) == 1 && output.node_pool_names.user == "user"
    error_message = "Expected one additional user node pool."
  }

  assert {
    condition     = output.diagnostics_enabled == true && output.role_assignment_count == 3
    error_message = "Diagnostics and role assignments should be enabled in the platform scenario."
  }
}

run "plan_public_api_with_authorized_ranges" {
  command = plan

  variables {
    resource_group_name             = "rg-ba-cc-prd-shared-management"
    location                        = "canadacentral"
    name                            = "aks-iactest-pub-001"
    app_env                         = "test"
    private_cluster_enabled         = false
    api_server_authorized_ip_ranges = ["203.0.113.10/32"]
    app_admin_group                 = []
    app_user_group                  = []
  }

  assert {
    condition     = output.private_cluster_enabled == false
    error_message = "Public API scenario should disable private cluster mode."
  }
}
