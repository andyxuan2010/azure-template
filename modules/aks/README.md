# Azure Kubernetes Service

Provisions Azure Kubernetes Service with private API access, Microsoft Entra and Azure RBAC integration, Workload Identity, advanced networking, node pools, observability, diagnostics, and cluster-scope role assignments.

## Features

- Private cluster, Azure RBAC, disabled local accounts, OIDC, Workload Identity, Azure Policy, image cleaner, and node OS upgrades as secure defaults.
- Explicit or generated cluster naming.
- System-assigned or user-assigned control-plane identity.
- AKS-managed, caller-managed, or looked-up private DNS.
- Azure CNI Overlay and Cilium-ready networking.
- Configurable system pool and additional user or system node pools.
- Cluster autoscaler, maintenance windows, CSI storage, Secrets Store CSI, KMS, ingress, routing, proxy, Linux, and Windows profiles.
- Container Insights, Defender for Containers, managed Prometheus, and Azure Monitor diagnostics.
- Built-in admin/user access and generic Azure role assignments.

## Resources Created

The module always creates an AKS cluster. Depending on its inputs, it can also create:

- additional AKS node pools;
- Azure Monitor diagnostic settings;
- Azure role assignments;
- a random suffix used by generated naming.

AKS creates and manages a separate node resource group outside the direct Terraform resource list.

## Prerequisites and Dependencies

- An existing resource group.
- AzureRM and AzureAD providers configured by the caller.
- For production networking, an existing subnet sized for the selected network and scaling model.
- Optional private DNS zone, user-assigned identity, Log Analytics workspace, Application Gateway, Key Vault/KMS dependencies, and diagnostic destinations.
- Sufficient Azure quota for the node VM sizes and zones.

See the repository [module dependency guide](../../docs/MODULE_USAGE_AND_DEPENDENCIES.md) and the [AKS `kubelogin` guide](../../docs/AKS_AUTHENTICATION_KUBELOGIN.md).

## Provider Configuration

Provider configurations and credentials belong in the calling root module:

```hcl
provider "azurerm" {
  features {}
}

provider "azuread" {}
```

When private DNS is supplied by name, the default AzureRM provider must be able to read the zone. The Terraform identity also needs permission to create AKS and any requested role assignments.

## Basic Usage

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  workload_name       = "platform"
  app_env             = "prod"
  private_dns_zone_id = "System"

  default_node_pool = {
    name                 = "system"
    vm_size              = "Standard_D4s_v5"
    auto_scaling_enabled = true
    min_count            = 3
    max_count            = 6
    zones                = ["1", "2", "3"]
    vnet_subnet_id       = module.vnet.subnet_ids["aks"]
  }

  tags = {
    Owner = "Platform"
  }
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)

## Important Behavior and Secure Defaults

- Private API access, Microsoft Entra/Azure RBAC, disabled local accounts, OIDC, and Workload Identity are enabled by default.
- Prefer private clusters. A public API should always use reviewed authorized IP ranges.
- Use `temporary_name_for_rotation` before changing an immutable default-pool property that requires rotation.
- Keep a system node pool available for critical add-ons.
- Plan address spaces and subnet capacity for maximum autoscaling, upgrades, and the selected network plugin.
- Set exactly one of `role_definition_name` or `role_definition_id` in each generic role assignment.
- Enabling monitoring features requires the corresponding destination and permission inputs.

## Networking and Private Connectivity

The default network model is Azure CNI Overlay with Cilium. Review service, pod, and VNet address spaces for overlap before deployment.

Private DNS can use:

- `System` for an AKS-managed zone;
- `None` for a custom DNS path managed outside AKS;
- a private DNS zone resource ID;
- a zone name and resource group for lookup.

Private clusters also require network and DNS reachability from administration and CI/CD hosts.

## Identity and RBAC

The default control-plane identity is system-assigned. Supply `identity_ids` to use a user-assigned identity. Prefer Workload Identity for applications rather than node or pod identity workarounds.

The module can grant cluster-scoped Azure Kubernetes Service RBAC roles to:

- `app_admin_group`;
- `app_user_group`;
- the current Terraform execution identity;
- additional principals in `role_assignments`.

Azure subscription or resource-group Contributor access alone does not grant Kubernetes data-plane permissions.

## Naming and Tagging

Set `name` explicitly or generate it from `name_prefix`, `workload_name`, environment, location code, and instance. Random suffixes are opt-in.

The module merges inherited resource-group tags with caller tags without adding module marker tags. Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

The current test is a mock-provider unit plan test:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

It contains plan and expected-failure runs only. The AzureRM and AzureAD providers are mocked, so it does not authenticate to Azure or apply a cluster.

## Known Limitations

- Private-cluster administration depends on external network and DNS connectivity.
- Azure service availability, supported Kubernetes versions, VM SKUs, zones, and quotas vary by region and subscription.
- Add-ons such as Defender, Container Insights, Application Gateway ingress, KMS, and Web App Routing can introduce separate service costs and permission requirements.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0, < 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.terraform_execution_identity_cluster_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_group_object_ids"></a> [admin\_group\_object\_ids](#input\_admin\_group\_object\_ids) | Additional Microsoft Entra group object IDs configured as AKS administrator groups. | `list(string)` | `[]` | no |
| <a name="input_api_server_access_profile"></a> [api\_server\_access\_profile](#input\_api\_server\_access\_profile) | Optional AKS API server access profile. Use subnet\_id and virtual\_network\_integration\_enabled for API Server VNet Integration. | <pre>object({<br>    authorized_ip_ranges                = optional(list(string), [])<br>    subnet_id                           = optional(string)<br>    virtual_network_integration_enabled = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | Backward-compatible shortcut for CIDR ranges allowed to reach the AKS API server when the cluster is public. | `list(string)` | `[]` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Microsoft Entra group display names or object IDs that should receive AKS admin treatment. | `list(string)` | `[]` | no |
| <a name="input_app_admin_role_definition_name"></a> [app\_admin\_role\_definition\_name](#input\_app\_admin\_role\_definition\_name) | Azure role assigned to app\_admin\_group principals at the AKS cluster scope. | `string` | `"Contributor"` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Microsoft Entra group display names or object IDs that should receive reader access on the AKS cluster resource. | `list(string)` | `[]` | no |
| <a name="input_app_user_role_definition_name"></a> [app\_user\_role\_definition\_name](#input\_app\_user\_role\_definition\_name) | Azure role assigned to app\_user\_group principals at the AKS cluster scope. | `string` | `"Reader"` | no |
| <a name="input_auto_scaler_profile"></a> [auto\_scaler\_profile](#input\_auto\_scaler\_profile) | Optional cluster autoscaler profile. | <pre>object({<br>    balance_similar_node_groups                   = optional(bool)<br>    daemonset_eviction_for_empty_nodes_enabled    = optional(bool)<br>    daemonset_eviction_for_occupied_nodes_enabled = optional(bool)<br>    empty_bulk_delete_max                         = optional(string)<br>    expander                                      = optional(string)<br>    ignore_daemonsets_utilization_enabled         = optional(bool)<br>    max_graceful_termination_sec                  = optional(string)<br>    max_node_provisioning_time                    = optional(string)<br>    max_unready_nodes                             = optional(number)<br>    max_unready_percentage                        = optional(number)<br>    new_pod_scale_up_delay                        = optional(string)<br>    scale_down_delay_after_add                    = optional(string)<br>    scale_down_delay_after_delete                 = optional(string)<br>    scale_down_delay_after_failure                = optional(string)<br>    scale_down_unneeded                           = optional(string)<br>    scale_down_unready                            = optional(string)<br>    scale_down_utilization_threshold              = optional(string)<br>    scan_interval                                 = optional(string)<br>    skip_nodes_with_local_storage                 = optional(bool)<br>    skip_nodes_with_system_pods                   = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_automatic_upgrade_channel"></a> [automatic\_upgrade\_channel](#input\_automatic\_upgrade\_channel) | Automatic upgrade channel for AKS. | `string` | `"patch"` | no |
| <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled) | Whether to enable the Azure Policy AKS add-on. | `bool` | `true` | no |
| <a name="input_azure_rbac_enabled"></a> [azure\_rbac\_enabled](#input\_azure\_rbac\_enabled) | Whether Azure RBAC for Kubernetes Authorization is enabled. | `bool` | `true` | no |
| <a name="input_cost_analysis_enabled"></a> [cost\_analysis\_enabled](#input\_cost\_analysis\_enabled) | Whether AKS cost analysis is enabled. Requires sku\_tier Standard or Premium. | `bool` | `false` | no |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Default system node pool configuration. | <pre>object({<br>    name                          = optional(string, "system")<br>    vm_size                       = optional(string, "Standard_D4s_v5")<br>    node_count                    = optional(number, 1)<br>    enable_auto_scaling           = optional(bool)<br>    auto_scaling_enabled          = optional(bool)<br>    min_count                     = optional(number)<br>    max_count                     = optional(number)<br>    zones                         = optional(list(string), [])<br>    os_disk_size_gb               = optional(number, 128)<br>    os_disk_type                  = optional(string, "Managed")<br>    os_sku                        = optional(string, "Ubuntu")<br>    max_pods                      = optional(number)<br>    vnet_subnet_id                = optional(string)<br>    pod_subnet_id                 = optional(string)<br>    only_critical_addons_enabled  = optional(bool, false)<br>    orchestrator_version          = optional(string)<br>    type                          = optional(string, "VirtualMachineScaleSets")<br>    temporary_name_for_rotation   = optional(string)<br>    host_encryption_enabled       = optional(bool, false)<br>    ultra_ssd_enabled             = optional(bool, false)<br>    fips_enabled                  = optional(bool, false)<br>    kubelet_disk_type             = optional(string)<br>    node_labels                   = optional(map(string), {})<br>    node_public_ip_enabled        = optional(bool, false)<br>    node_public_ip_prefix_id      = optional(string)<br>    capacity_reservation_group_id = optional(string)<br>    host_group_id                 = optional(string)<br>    proximity_placement_group_id  = optional(string)<br>    scale_down_mode               = optional(string)<br>    snapshot_id                   = optional(string)<br>    tags                          = optional(map(string), {})<br>    workload_runtime              = optional(string)<br>    kubelet_config = optional(object({<br>      allowed_unsafe_sysctls    = optional(list(string))<br>      container_log_max_files   = optional(number)<br>      container_log_max_line    = optional(number)<br>      container_log_max_size_mb = optional(number)<br>      cpu_cfs_quota_enabled     = optional(bool)<br>      cpu_cfs_quota_period      = optional(string)<br>      cpu_manager_policy        = optional(string)<br>      image_gc_high_threshold   = optional(number)<br>      image_gc_low_threshold    = optional(number)<br>      pod_max_pid               = optional(number)<br>      topology_manager_policy   = optional(string)<br>    }))<br>    linux_os_config = optional(object({<br>      swap_file_size_mb             = optional(number)<br>      transparent_huge_page         = optional(string)<br>      transparent_huge_page_defrag  = optional(string)<br>      transparent_huge_page_enabled = optional(string)<br>    }))<br>    node_network_profile = optional(object({<br>      application_security_group_ids = optional(list(string), [])<br>      node_public_ip_tags            = optional(map(string), {})<br>      allowed_host_ports = optional(list(object({<br>        port_start = optional(number)<br>        port_end   = optional(number)<br>        protocol   = optional(string)<br>      })), [])<br>    }))<br>    upgrade_settings = optional(object({<br>      max_surge                     = optional(string)<br>      drain_timeout_in_minutes      = optional(number)<br>      node_soak_duration_in_minutes = optional(number)<br>      undrainable_node_behavior     = optional(string)<br>    }))<br>  })</pre> | `{}` | no |
| <a name="input_diagnostic_eventhub_authorization_rule_id"></a> [diagnostic\_eventhub\_authorization\_rule\_id](#input\_diagnostic\_eventhub\_authorization\_rule\_id) | Optional Event Hub authorization rule ID used to stream diagnostics. | `string` | `""` | no |
| <a name="input_diagnostic_eventhub_name"></a> [diagnostic\_eventhub\_name](#input\_diagnostic\_eventhub\_name) | Optional Event Hub name used to stream diagnostics. | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | Diagnostic log categories to enable for AKS. Use AllLogs to emit the provider category group instead of individual categories. | `list(string)` | <pre>[<br>  "AllLogs"<br>]</pre> | no |
| <a name="input_diagnostic_log_category_groups"></a> [diagnostic\_log\_category\_groups](#input\_diagnostic\_log\_category\_groups) | Diagnostic log category groups to enable, for example allLogs or audit. | `list(string)` | `[]` | no |
| <a name="input_diagnostic_metric_categories"></a> [diagnostic\_metric\_categories](#input\_diagnostic\_metric\_categories) | Diagnostic metric categories to enable for AKS. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | Optional diagnostic setting name. Defaults to <aks-name>-diagnostic-setting. | `string` | `""` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Optional Storage Account ID used to archive diagnostics. | `string` | `""` | no |
| <a name="input_dns_prefix"></a> [dns\_prefix](#input\_dns\_prefix) | Optional DNS prefix for the AKS API server. If empty, the module derives one from the cluster name. | `string` | `""` | no |
| <a name="input_dns_prefix_private_cluster"></a> [dns\_prefix\_private\_cluster](#input\_dns\_prefix\_private\_cluster) | Optional DNS prefix for private AKS clusters. When set, dns\_prefix is not used. | `string` | `""` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create a diagnostic setting for the AKS cluster. Diagnostics are also enabled automatically when any diagnostic destination ID is supplied. | `bool` | `false` | no |
| <a name="input_http_proxy_config"></a> [http\_proxy\_config](#input\_http\_proxy\_config) | Optional HTTP proxy configuration. | <pre>object({<br>    http_proxy  = optional(string)<br>    https_proxy = optional(string)<br>    no_proxy    = optional(list(string))<br>    trusted_ca  = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | Optional user-assigned managed identity IDs for the AKS control plane. When empty, a system-assigned identity is used. | `list(string)` | `[]` | no |
| <a name="input_image_cleaner_enabled"></a> [image\_cleaner\_enabled](#input\_image\_cleaner\_enabled) | Whether to enable the AKS image cleaner feature on cluster nodes. | `bool` | `true` | no |
| <a name="input_image_cleaner_interval_hours"></a> [image\_cleaner\_interval\_hours](#input\_image\_cleaner\_interval\_hours) | Interval in hours for AKS image cleaner when enabled. | `number` | `48` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether generated AKS names include app\_env. | `bool` | `true` | no |
| <a name="input_ingress_application_gateway"></a> [ingress\_application\_gateway](#input\_ingress\_application\_gateway) | Optional Application Gateway ingress controller add-on configuration. | <pre>object({<br>    gateway_id   = optional(string)<br>    gateway_name = optional(string)<br>    subnet_cidr  = optional(string)<br>    subnet_id    = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into AKS resources. The module only reads the resource group when this is true or location is empty. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when generated names do not use a random suffix. | `string` | `"001"` | no |
| <a name="input_key_management_service"></a> [key\_management\_service](#input\_key\_management\_service) | Optional KMS etcd encryption configuration. | <pre>object({<br>    key_vault_key_id         = string<br>    key_vault_network_access = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#input\_key\_vault\_secrets\_provider\_enabled) | Whether the Azure Key Vault Secrets Store CSI driver is enabled. | `bool` | `false` | no |
| <a name="input_key_vault_secrets_provider_secret_rotation_enabled"></a> [key\_vault\_secrets\_provider\_secret\_rotation\_enabled](#input\_key\_vault\_secrets\_provider\_secret\_rotation\_enabled) | Whether secret rotation is enabled for the Azure Key Vault Secrets Store CSI driver. | `bool` | `false` | no |
| <a name="input_key_vault_secrets_provider_secret_rotation_interval"></a> [key\_vault\_secrets\_provider\_secret\_rotation\_interval](#input\_key\_vault\_secrets\_provider\_secret\_rotation\_interval) | The interval to check for secret changes. Only applies if key\_vault\_secrets\_provider\_secret\_rotation\_enabled is true. | `string` | `"2m"` | no |
| <a name="input_kubelet_identity"></a> [kubelet\_identity](#input\_kubelet\_identity) | Optional kubelet user-assigned identity configuration. | <pre>object({<br>    client_id                 = string<br>    object_id                 = string<br>    user_assigned_identity_id = string<br>  })</pre> | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Optional Kubernetes version for the AKS control plane. Leave null to let AKS choose the default supported version. | `string` | `null` | no |
| <a name="input_linux_profile"></a> [linux\_profile](#input\_linux\_profile) | Optional Linux profile for SSH access. | <pre>object({<br>    admin_username = string<br>    ssh_key = object({<br>      key_data = string<br>    })<br>  })</pre> | `null` | no |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | Whether local AKS admin accounts are disabled. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where to deploy the AKS cluster. If empty, the resource group's location is used. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the AKS cluster name is generated. | `string` | `""` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Diagnostic Log Analytics destination type. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace resource ID for diagnostics and optional add-ons. | `string` | `""` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Optional allowed and not-allowed cluster maintenance windows. | <pre>object({<br>    allowed = optional(list(object({<br>      day   = string<br>      hours = list(number)<br>    })), [])<br>    not_allowed = optional(list(object({<br>      start = string<br>      end   = string<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_maintenance_window_auto_upgrade"></a> [maintenance\_window\_auto\_upgrade](#input\_maintenance\_window\_auto\_upgrade) | Optional maintenance window for cluster auto-upgrades. | <pre>object({<br>    frequency    = string<br>    interval     = number<br>    duration     = number<br>    day_of_week  = optional(string)<br>    day_of_month = optional(number)<br>    week_index   = optional(string)<br>    start_time   = optional(string)<br>    start_date   = optional(string)<br>    utc_offset   = optional(string)<br>    not_allowed = optional(list(object({<br>      start = string<br>      end   = string<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_maintenance_window_node_os"></a> [maintenance\_window\_node\_os](#input\_maintenance\_window\_node\_os) | Optional maintenance window for node OS image upgrades. | <pre>object({<br>    frequency    = string<br>    interval     = number<br>    duration     = number<br>    day_of_week  = optional(string)<br>    day_of_month = optional(number)<br>    week_index   = optional(string)<br>    start_time   = optional(string)<br>    start_date   = optional(string)<br>    utc_offset   = optional(string)<br>    not_allowed = optional(list(object({<br>      start = string<br>      end   = string<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_microsoft_defender_enabled"></a> [microsoft\_defender\_enabled](#input\_microsoft\_defender\_enabled) | Whether Microsoft Defender for Containers profile is enabled. Also enabled automatically when microsoft\_defender\_log\_analytics\_workspace\_id is supplied. | `bool` | `false` | no |
| <a name="input_microsoft_defender_log_analytics_workspace_id"></a> [microsoft\_defender\_log\_analytics\_workspace\_id](#input\_microsoft\_defender\_log\_analytics\_workspace\_id) | Log Analytics workspace ID for Microsoft Defender for Containers. | `string` | `""` | no |
| <a name="input_monitor_metrics"></a> [monitor\_metrics](#input\_monitor\_metrics) | Managed Prometheus monitor metrics allow-lists. | <pre>object({<br>    annotations_allowed = optional(string)<br>    labels_allowed      = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_monitor_metrics_enabled"></a> [monitor\_metrics\_enabled](#input\_monitor\_metrics\_enabled) | Whether the managed Prometheus monitor metrics profile is enabled. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | AKS cluster name. Leave empty to auto-generate a standardized name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the AKS cluster name is generated. | `string` | `"aks"` | no |
| <a name="input_network_profile"></a> [network\_profile](#input\_network\_profile) | AKS network profile configuration. | <pre>object({<br>    network_plugin      = optional(string, "azure")<br>    network_plugin_mode = optional(string, "overlay")<br>    network_policy      = optional(string, "cilium")<br>    network_data_plane  = optional(string, "cilium")<br>    network_mode        = optional(string)<br>    service_cidr        = optional(string)<br>    service_cidrs       = optional(list(string))<br>    dns_service_ip      = optional(string)<br>    pod_cidr            = optional(string)<br>    pod_cidrs           = optional(list(string))<br>    ip_versions         = optional(list(string), ["IPv4"])<br>    load_balancer_sku   = optional(string, "standard")<br>    outbound_type       = optional(string, "loadBalancer")<br>    load_balancer_profile = optional(object({<br>      backend_pool_type           = optional(string)<br>      idle_timeout_in_minutes     = optional(number)<br>      managed_outbound_ip_count   = optional(number)<br>      managed_outbound_ipv6_count = optional(number)<br>      outbound_ip_address_ids     = optional(list(string))<br>      outbound_ip_prefix_ids      = optional(list(string))<br>      outbound_ports_allocated    = optional(number)<br>    }))<br>    nat_gateway_profile = optional(object({<br>      idle_timeout_in_minutes   = optional(number)<br>      managed_outbound_ip_count = optional(number)<br>    }))<br>    advanced_networking = optional(object({<br>      observability_enabled = optional(bool)<br>      security_enabled      = optional(bool)<br>    }))<br>  })</pre> | `{}` | no |
| <a name="input_node_os_upgrade_channel"></a> [node\_os\_upgrade\_channel](#input\_node\_os\_upgrade\_channel) | Node OS image upgrade channel for AKS node pools. | `string` | `"NodeImage"` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Additional AKS node pools keyed by Terraform map key. | <pre>map(object({<br>    name                          = optional(string)<br>    vm_size                       = string<br>    mode                          = optional(string, "User")<br>    os_type                       = optional(string, "Linux")<br>    os_sku                        = optional(string)<br>    node_count                    = optional(number)<br>    auto_scaling_enabled          = optional(bool, true)<br>    min_count                     = optional(number)<br>    max_count                     = optional(number)<br>    zones                         = optional(list(string), [])<br>    orchestrator_version          = optional(string)<br>    max_pods                      = optional(number)<br>    vnet_subnet_id                = optional(string)<br>    pod_subnet_id                 = optional(string)<br>    os_disk_size_gb               = optional(number)<br>    os_disk_type                  = optional(string)<br>    kubelet_disk_type             = optional(string)<br>    node_labels                   = optional(map(string), {})<br>    node_taints                   = optional(list(string), [])<br>    node_public_ip_enabled        = optional(bool, false)<br>    node_public_ip_prefix_id      = optional(string)<br>    priority                      = optional(string)<br>    eviction_policy               = optional(string)<br>    spot_max_price                = optional(number)<br>    scale_down_mode               = optional(string)<br>    temporary_name_for_rotation   = optional(string)<br>    ultra_ssd_enabled             = optional(bool, false)<br>    host_encryption_enabled       = optional(bool, false)<br>    fips_enabled                  = optional(bool, false)<br>    capacity_reservation_group_id = optional(string)<br>    host_group_id                 = optional(string)<br>    proximity_placement_group_id  = optional(string)<br>    snapshot_id                   = optional(string)<br>    workload_runtime              = optional(string)<br>    gpu_driver                    = optional(string)<br>    gpu_instance                  = optional(string)<br>    tags                          = optional(map(string), {})<br>    kubelet_config = optional(object({<br>      allowed_unsafe_sysctls    = optional(list(string))<br>      container_log_max_files   = optional(number)<br>      container_log_max_line    = optional(number)<br>      container_log_max_size_mb = optional(number)<br>      cpu_cfs_quota_enabled     = optional(bool)<br>      cpu_cfs_quota_period      = optional(string)<br>      cpu_manager_policy        = optional(string)<br>      image_gc_high_threshold   = optional(number)<br>      image_gc_low_threshold    = optional(number)<br>      pod_max_pid               = optional(number)<br>      topology_manager_policy   = optional(string)<br>    }))<br>    linux_os_config = optional(object({<br>      swap_file_size_mb             = optional(number)<br>      transparent_huge_page         = optional(string)<br>      transparent_huge_page_defrag  = optional(string)<br>      transparent_huge_page_enabled = optional(string)<br>    }))<br>    node_network_profile = optional(object({<br>      application_security_group_ids = optional(list(string), [])<br>      node_public_ip_tags            = optional(map(string), {})<br>      allowed_host_ports = optional(list(object({<br>        port_start = optional(number)<br>        port_end   = optional(number)<br>        protocol   = optional(string)<br>      })), [])<br>    }))<br>    upgrade_settings = optional(object({<br>      max_surge                     = optional(string)<br>      max_unavailable               = optional(string)<br>      drain_timeout_in_minutes      = optional(number)<br>      node_soak_duration_in_minutes = optional(number)<br>      undrainable_node_behavior     = optional(string)<br>    }))<br>    windows_profile = optional(object({<br>      outbound_nat_enabled = optional(bool)<br>    }))<br>    timeouts = optional(object({<br>      create = optional(string)<br>      read   = optional(string)<br>      update = optional(string)<br>      delete = optional(string)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_node_resource_group_name"></a> [node\_resource\_group\_name](#input\_node\_resource\_group\_name) | Optional custom node resource group name for AKS managed infrastructure. When empty, Azure generates the node resource group. | `string` | `""` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Whether the cluster OIDC issuer is enabled. | `bool` | `true` | no |
| <a name="input_oms_agent_enabled"></a> [oms\_agent\_enabled](#input\_oms\_agent\_enabled) | Whether to enable the Container Insights OMS agent. Also enabled automatically when oms\_agent\_log\_analytics\_workspace\_id is supplied. | `bool` | `false` | no |
| <a name="input_oms_agent_log_analytics_workspace_id"></a> [oms\_agent\_log\_analytics\_workspace\_id](#input\_oms\_agent\_log\_analytics\_workspace\_id) | Log Analytics workspace ID for Container Insights. | `string` | `""` | no |
| <a name="input_oms_agent_msi_auth_for_monitoring_enabled"></a> [oms\_agent\_msi\_auth\_for\_monitoring\_enabled](#input\_oms\_agent\_msi\_auth\_for\_monitoring\_enabled) | Whether OMS agent uses managed identity authentication. | `bool` | `true` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Whether the AKS cluster API server is private. | `bool` | `true` | no |
| <a name="input_private_cluster_public_fqdn_enabled"></a> [private\_cluster\_public\_fqdn\_enabled](#input\_private\_cluster\_public\_fqdn\_enabled) | Whether a private AKS cluster also exposes a public FQDN endpoint. | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Optional private DNS zone resource ID for a private AKS cluster. Use System for AKS-managed DNS or None for custom DNS. | `string` | `""` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Optional existing private DNS zone name used when private\_dns\_zone\_id is not supplied. | `string` | `""` | no |
| <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name) | Optional resource group containing private\_dns\_zone\_name. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the AKS cluster will be deployed. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments scoped to the AKS cluster. | <pre>map(object({<br>    principal_id                           = string<br>    principal_type                         = optional(string)<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    name                                   = optional(string)<br>    description                            = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_role_based_access_control_enabled"></a> [role\_based\_access\_control\_enabled](#input\_role\_based\_access\_control\_enabled) | Whether Kubernetes RBAC is enabled. | `bool` | `true` | no |
| <a name="input_run_command_enabled"></a> [run\_command\_enabled](#input\_run\_command\_enabled) | Whether AKS run command is enabled. | `bool` | `true` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | AKS SKU tier. | `string` | `"Free"` | no |
| <a name="input_storage_profile"></a> [storage\_profile](#input\_storage\_profile) | AKS storage CSI driver profile. | <pre>object({<br>    blob_driver_enabled         = optional(bool, false)<br>    disk_driver_enabled         = optional(bool, true)<br>    file_driver_enabled         = optional(bool, true)<br>    snapshot_controller_enabled = optional(bool, true)<br>  })</pre> | `null` | no |
| <a name="input_support_plan"></a> [support\_plan](#input\_support\_plan) | AKS support plan. | `string` | `"KubernetesOfficial"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to AKS resources. | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Optional Microsoft Entra tenant ID for AKS Azure AD RBAC. Leave empty to let AzureRM use the current tenant. | `string` | `""` | no |
| <a name="input_terraform_execution_aks_role"></a> [terraform\_execution\_aks\_role](#input\_terraform\_execution\_aks\_role) | Optional Azure Kubernetes Service RBAC role to assign to the current Terraform execution identity on the AKS cluster. | `string` | `""` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional AKS cluster operation timeouts. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_upgrade_override"></a> [upgrade\_override](#input\_upgrade\_override) | Optional force-upgrade override. | <pre>object({<br>    force_upgrade_enabled = bool<br>    effective_until       = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated AKS names should include a random suffix. | `bool` | `true` | no |
| <a name="input_web_app_routing"></a> [web\_app\_routing](#input\_web\_app\_routing) | Optional Web App Routing add-on configuration. | <pre>object({<br>    dns_zone_ids             = list(string)<br>    default_nginx_controller = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_windows_profile"></a> [windows\_profile](#input\_windows\_profile) | Optional Windows profile required for Windows node pools. | <pre>object({<br>    admin_username = string<br>    admin_password = string<br>    license        = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |
| <a name="input_workload_autoscaler_profile"></a> [workload\_autoscaler\_profile](#input\_workload\_autoscaler\_profile) | Optional workload autoscaler profile. | <pre>object({<br>    keda_enabled                    = optional(bool, false)<br>    vertical_pod_autoscaler_enabled = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Whether AKS Workload Identity is enabled. | `bool` | `true` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the AKS cluster name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of admin role assignment IDs keyed by app\_admin\_group principal ID. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of user role assignment IDs keyed by app\_user\_group principal ID. |
| <a name="output_azure_policy_enabled"></a> [azure\_policy\_enabled](#output\_azure\_policy\_enabled) | Whether the Azure Policy AKS add-on is enabled. |
| <a name="output_azure_rbac_enabled"></a> [azure\_rbac\_enabled](#output\_azure\_rbac\_enabled) | Whether Azure RBAC for Kubernetes Authorization is enabled. |
| <a name="output_current_kubernetes_version"></a> [current\_kubernetes\_version](#output\_current\_kubernetes\_version) | The current Kubernetes version running on the AKS cluster. |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | The ID of the AKS diagnostic setting, if created. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether AKS diagnostic settings are enabled. |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The public FQDN of the AKS API server when available. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the AKS cluster. |
| <a name="output_identity_ids"></a> [identity\_ids](#output\_identity\_ids) | User-assigned managed identity IDs configured on the AKS control plane. |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | The principal ID of the AKS managed identity. |
| <a name="output_identity_tenant_id"></a> [identity\_tenant\_id](#output\_identity\_tenant\_id) | The tenant ID of the AKS managed identity. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | Managed identity type configured on the AKS cluster. |
| <a name="output_image_cleaner_enabled"></a> [image\_cleaner\_enabled](#output\_image\_cleaner\_enabled) | Whether the AKS image cleaner feature is enabled. |
| <a name="output_key_vault_secrets_provider_identity"></a> [key\_vault\_secrets\_provider\_identity](#output\_key\_vault\_secrets\_provider\_identity) | The Key Vault Secrets Provider identity block when the addon is enabled. |
| <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity) | The kubelet identity block exposed by AKS. |
| <a name="output_kubernetes_version"></a> [kubernetes\_version](#output\_kubernetes\_version) | The resolved Kubernetes version of the AKS cluster. |
| <a name="output_local_account_disabled"></a> [local\_account\_disabled](#output\_local\_account\_disabled) | Whether local AKS admin accounts are disabled. |
| <a name="output_location"></a> [location](#output\_location) | The location of the AKS cluster. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | Short location code used for generated naming. |
| <a name="output_microsoft_defender_enabled"></a> [microsoft\_defender\_enabled](#output\_microsoft\_defender\_enabled) | Whether Microsoft Defender for Containers profile is enabled. |
| <a name="output_monitor_metrics_enabled"></a> [monitor\_metrics\_enabled](#output\_monitor\_metrics\_enabled) | Whether managed Prometheus monitor metrics are enabled. |
| <a name="output_name"></a> [name](#output\_name) | The name of the AKS cluster. |
| <a name="output_node_pool_ids"></a> [node\_pool\_ids](#output\_node\_pool\_ids) | Map of additional node pool IDs keyed by input key. |
| <a name="output_node_pool_names"></a> [node\_pool\_names](#output\_node\_pool\_names) | Map of additional node pool names keyed by input key. |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | The node resource group managed by AKS. |
| <a name="output_node_resource_group_id"></a> [node\_resource\_group\_id](#output\_node\_resource\_group\_id) | The node resource group ID managed by AKS. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | The OIDC issuer URL when OIDC is enabled. |
| <a name="output_oms_agent_enabled"></a> [oms\_agent\_enabled](#output\_oms\_agent\_enabled) | Whether Container Insights OMS agent is enabled. |
| <a name="output_portal_fqdn"></a> [portal\_fqdn](#output\_portal\_fqdn) | The Azure portal FQDN for the AKS cluster. |
| <a name="output_private_cluster_enabled"></a> [private\_cluster\_enabled](#output\_private\_cluster\_enabled) | Whether the AKS cluster API server is private. |
| <a name="output_private_dns_zone_id"></a> [private\_dns\_zone\_id](#output\_private\_dns\_zone\_id) | The effective private DNS zone ID used by the AKS cluster when private cluster mode is enabled. |
| <a name="output_private_fqdn"></a> [private\_fqdn](#output\_private\_fqdn) | The private FQDN of the AKS API server when private cluster mode is enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group containing the AKS cluster. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of AKS role assignments managed by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of additional role assignment IDs keyed by input key. |
| <a name="output_sku_tier"></a> [sku\_tier](#output\_sku\_tier) | AKS SKU tier. |
| <a name="output_tags"></a> [tags](#output\_tags) | The effective tags assigned to the AKS cluster. |
| <a name="output_terraform_execution_identity_cluster_access_role_assignment_id"></a> [terraform\_execution\_identity\_cluster\_access\_role\_assignment\_id](#output\_terraform\_execution\_identity\_cluster\_access\_role\_assignment\_id) | The Azure Kubernetes Service RBAC role assignment ID granted to the current Terraform execution identity, if enabled. |
| <a name="output_workload_identity_enabled"></a> [workload\_identity\_enabled](#output\_workload\_identity\_enabled) | Whether Microsoft Entra Workload ID is enabled. |
<!-- END_TF_DOCS -->
