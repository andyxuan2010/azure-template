# AKS Module

Provision Azure Kubernetes Service with secure defaults, standardized naming and tags, private API support, Azure RBAC, Workload Identity, managed identities, advanced networking, node pools, observability, maintenance windows, diagnostics, and RBAC assignments.

## Features

- Secure baseline with private cluster, Azure RBAC, local admin accounts disabled, OIDC issuer, Workload Identity, Azure Policy, node OS upgrades, and image cleaner enabled by default.
- Standard generated naming using `name_prefix`, `workload_name`, `app_env`, `location_code`, and optional random suffixes.
- Standard tags including `ManagedBy`, `module`, `name`, `app_env`, and environment-specific tags.
- System-assigned control-plane identity by default, with optional user-assigned identity and kubelet identity.
- Private DNS options for `System`, `None`, direct private DNS zone ID, or private DNS zone lookup.
- Azure CNI overlay and Cilium-ready network profile defaults, with support for load balancer, NAT gateway, dual stack inputs, and advanced networking.
- Configurable default system node pool and additional user/system node pools.
- Optional autoscaler profile, maintenance windows, storage CSI profile, Workload Autoscaler, Key Vault Secrets Store CSI driver, KMS, Application Gateway ingress, Web App Routing, HTTP proxy, Linux profile, and Windows profile.
- Optional Container Insights, Microsoft Defender for Containers, and managed Prometheus metrics.
- Diagnostics to Log Analytics, Storage Account archive, and Event Hub with category and category-group support.
- Built-in admin/user role assignments plus generic cluster-scope RBAC assignments.
- Mock-provider Terraform tests for fast plan coverage without creating live Azure resources.

## Basic Usage

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
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

  tags = {
    Owner = "Platform"
  }
}
```

## Platform Cluster

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
  name                = "aks-platform-prod-eus-001"
  app_env             = "prod"
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
    user = {
      vm_size              = "Standard_D4s_v5"
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

  network_profile = {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    service_cidr        = "10.10.0.0/16"
    dns_service_ip      = "10.10.0.10"
    pod_cidr            = "10.244.0.0/16"
    outbound_type       = "loadBalancer"
  }
}
```

## Observability

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
  name                = "aks-observability-prod-eus-001"
  sku_tier            = "Standard"

  log_analytics_workspace_id     = module.log_analytics.id
  oms_agent_enabled              = true
  microsoft_defender_enabled     = true
  monitor_metrics_enabled        = true
  enable_diagnostics             = true
  log_analytics_destination_type = "Dedicated"
  diagnostic_log_categories      = ["AllLogs"]
}
```

## Testing

Run module checks from the module directory:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

`tests/live.tftest.hcl` uses Terraform mock providers, so it validates module behavior without creating live AKS clusters.
