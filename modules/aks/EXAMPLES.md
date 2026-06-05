# AKS Examples

## Private Baseline

```hcl
module "aks" {
  source = "../aks"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  workload_name       = "platform"
  app_env             = "prod"

  default_node_pool = {
    name                 = "system"
    vm_size              = "Standard_D4s_v5"
    auto_scaling_enabled = true
    min_count            = 3
    max_count            = 6
    zones                = ["1", "2", "3"]
    vnet_subnet_id       = module.vnet.subnet_ids["snet-aks"]
  }
}
```

## User-Assigned Identity And Extra Node Pool

```hcl
module "aks" {
  source = "../aks"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "aks-platform-prod-cc-001"
  sku_tier            = "Standard"

  identity_ids = [azurerm_user_assigned_identity.aks.id]

  default_node_pool = {
    name                        = "system"
    vm_size                     = "Standard_D4s_v5"
    auto_scaling_enabled        = true
    min_count                   = 3
    max_count                   = 6
    zones                       = ["1", "2", "3"]
    os_sku                      = "AzureLinux"
    vnet_subnet_id              = module.vnet.subnet_ids["snet-aks"]
    temporary_name_for_rotation = "sysrot"
    upgrade_settings = {
      max_surge = "33%"
    }
  }

  node_pools = {
    workload = {
      vm_size              = "Standard_D8s_v5"
      auto_scaling_enabled = true
      min_count            = 1
      max_count            = 5
      zones                = ["1", "2", "3"]
      vnet_subnet_id       = module.vnet.subnet_ids["snet-aks"]
      node_labels = {
        workload = "general"
      }
    }
  }
}
```

## Azure CNI Overlay With Cilium

```hcl
module "aks" {
  source = "../aks"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "aks-network-prod-cc-001"

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
}
```

## Observability And Security Add-ons

```hcl
module "aks" {
  source = "../aks"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "aks-observe-prod-cc-001"
  sku_tier            = "Standard"

  log_analytics_workspace_id = module.log_analytics.id

  oms_agent_enabled          = true
  microsoft_defender_enabled = true
  monitor_metrics_enabled    = true

  key_vault_secrets_provider_enabled                  = true
  key_vault_secrets_provider_secret_rotation_enabled  = true
  key_vault_secrets_provider_secret_rotation_interval = "2m"

  enable_diagnostics             = true
  log_analytics_destination_type = "Dedicated"
  diagnostic_log_categories      = ["AllLogs"]
  diagnostic_metric_categories   = ["AllMetrics"]
}
```

## Maintenance Windows

```hcl
module "aks" {
  source = "../aks"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "aks-maint-prod-cc-001"

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
}
```

## Public API With Authorized IPs

```hcl
module "aks" {
  source = "../aks"

  resource_group_name             = "rg-platform-test"
  location                        = "canadacentral"
  name                            = "aks-public-test-cc-001"
  app_env                         = "test"
  private_cluster_enabled         = false
  api_server_authorized_ip_ranges = ["203.0.113.10/32"]
}
```

## Notes

- Prefer private clusters for production and avoid public API access unless there is a clear operational requirement.
- Keep `local_account_disabled = true` and use Entra ID plus Azure RBAC for Kubernetes authorization.
- Prefer Workload Identity over pod-managed identity patterns.
- Use `temporary_name_for_rotation` before changing immutable default node pool fields.
