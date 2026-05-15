# Azure Kubernetes Service Module

Provision an Azure Kubernetes Service cluster with opinionated defaults for private access, Azure RBAC, workload identity, Azure Policy, and diagnostic integration.

## Highlights

- Private cluster by default.
- Azure RBAC and local account disablement enabled by default.
- OIDC issuer and workload identity enabled by default.
- Azure Policy add-on enabled by default.
- Image cleaner enabled by default.
- Optional API server IP allowlists for public clusters.
- Optional custom node resource group name.
- Optional Key Vault Secrets Provider add-on with secret rotation controls.
- Optional diagnostic settings to Log Analytics.

## Managed Resources

- `azurerm_kubernetes_cluster`
- `azurerm_monitor_diagnostic_setting`
- `azurerm_role_assignment`
- `random_string`

## Basic Usage

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name = "rg-example-prod"
  app_env             = "prod"

  default_node_pool = {
    vm_size        = "Standard_D4s_v5"
    node_count     = 1
    vnet_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Recommended Pattern

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name      = "rg-example-prod"
  name                     = "aks-example-prod-001"
  node_resource_group_name = "rg-example-prod-aks-nodes"
  app_env                  = "prod"
  sku_tier                 = "Standard"
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
    vnet_subnet_id      = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
    zones               = ["1", "2", "3"]
  }

  network_profile = {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  enable_diagnostics           = true
  log_analytics_workspace_id   = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<law>"
  diagnostic_metric_categories = ["AllMetrics"]

  tags = {
    ManagedBy = "Terraform"
    Workload  = "platform"
  }
}
```

## Important Inputs

- `resource_group_name`: Target resource group for the AKS cluster.
- `name`: Optional cluster name. When empty, the module generates one.
- `node_resource_group_name`: Optional custom node resource group name.
- `private_cluster_enabled`: Enables a private AKS API server. Defaults to `true`.
- `private_cluster_public_fqdn_enabled`: Optionally exposes a public FQDN for a private cluster. Defaults to `false`.
- `api_server_authorized_ip_ranges`: Optional CIDR allowlist for public clusters.
- `automatic_upgrade_channel`: AKS control plane and node pool upgrade channel.
- `node_os_upgrade_channel`: Node OS image upgrade channel.
- `default_node_pool`: System node pool sizing, scaling, subnet, zone, and disk settings.
- `network_profile`: CNI, policy, service CIDR, pod CIDR, and outbound access settings.
- `azure_policy_enabled`: Enables the Azure Policy add-on. Defaults to `true`.
- `image_cleaner_enabled`: Enables AKS image cleaner. Defaults to `true`.
- `enable_diagnostics`: Enables Azure Monitor diagnostic settings.
- `terraform_execution_aks_role`: Optional Azure Kubernetes Service RBAC role assignment for the Terraform execution identity.

## Notable Outputs

- `id`
- `name`
- `fqdn`
- `private_fqdn`
- `node_resource_group`
- `identity_principal_id`
- `kubelet_identity`
- `oidc_issuer_url`
- `azure_policy_enabled`
- `image_cleaner_enabled`
- `private_dns_zone_id`
- `diagnostic_setting_id`

## Notes

- When `private_cluster_enabled = true`, `api_server_authorized_ip_ranges` must remain empty.
- When `azure_rbac_enabled = true`, Azure resource roles such as `Contributor` do not by themselves grant `kubectl` access. Use `terraform_execution_aks_role` when the Terraform identity needs AKS data-plane access.
- For public clusters, prefer setting `api_server_authorized_ip_ranges` instead of leaving the API server broadly reachable.
- Prefer object IDs over display names in `app_admin_group` and `app_user_group` when group names are not globally unique.

## Testing

Run module tests from the module directory:

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
