# Azure Kubernetes Service Examples

## Example 1: Minimal Private Cluster

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name = "rg-example-prod"

  default_node_pool = {
    vnet_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
  }
}
```

## Example 2: Production-Oriented Baseline

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name       = "rg-example-prod"
  name                      = "aks-example-prod-001"
  node_resource_group_name  = "rg-example-prod-aks-nodes"
  app_env                   = "prod"
  sku_tier                  = "Standard"
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"

  app_admin_group = [
    "00000000-0000-0000-0000-000000000000",
  ]

  default_node_pool = {
    name                = "system"
    vm_size             = "Standard_D4s_v5"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    zones               = ["1", "2", "3"]
    vnet_subnet_id      = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
    os_disk_type        = "Managed"
  }

  network_profile = {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<law>"
}
```

## Example 3: Public Cluster With API Server Allowlist

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name             = "rg-example-dev"
  private_cluster_enabled         = false
  api_server_authorized_ip_ranges = ["203.0.113.10/32", "198.51.100.0/24"]

  default_node_pool = {
    vnet_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
  }
}
```

## Example 4: Grant AKS RBAC Access To The Terraform Identity

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name          = "rg-example-prod"
  azure_rbac_enabled           = true
  terraform_execution_aks_role = "Azure Kubernetes Service RBAC Cluster Admin"

  default_node_pool = {
    vnet_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
  }
}
```

## Notes

- Replace placeholder IDs and resource IDs with real values.
- Keep `api_server_authorized_ip_ranges` empty for private clusters.
- Prefer explicit subnet IDs for node pools.
- Prefer object IDs over display names for Entra groups.
