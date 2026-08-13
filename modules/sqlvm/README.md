# Azure SQL Server Virtual Machines

Provisions one or more Windows Server virtual machines for SQL Server workloads, including network interfaces, managed SQL data disks, optional domain join and bootstrap execution, and optional registration with the Azure SQL IaaS Agent extension.

## Features

- Creates multiple SQL VMs with explicit or generated Windows-compatible names.
- Supports dynamic or static private addresses and either Availability Zones or an existing Availability Set.
- Creates configurable data, log, and TempDB managed disks for every VM.
- Configures SQL licensing, connectivity, storage, assessment, patching, backup, and instance options through the SQL IaaS Agent extension.
- Supports system-assigned or user-assigned managed identity, optional domain join, and optional VM Run Command.
- Inherits resource-group tags when requested.

## Resources Created

The module always creates one network interface and one Windows VM per requested instance. It creates each configured managed disk and attachment for every VM.

SQL VM registrations are created when `enable_sql_iaas_extension` is enabled. Domain join extensions and VM Run Command resources are conditional. The resource group may be read for its location or tags but is never managed.

See [architecture](docs/architecture.md) for resource relationships and lifecycle boundaries.

## Prerequisites and Dependencies

- An existing resource group and subnet with connectivity appropriate for SQL Server administration and application traffic
- A permitted SQL Server Azure Marketplace image and sufficient regional compute/disk quota
- Local administrator credentials supplied from a secret store or protected pipeline variable
- Active Directory DNS reachability and credentials when domain join is enabled
- A separately managed Availability Set, SQL VM group, listener/load balancer, or Windows cluster when those patterns are required

## Provider Configuration

The caller must configure `hashicorp/azurerm` 4.x. The execution identity needs permissions for virtual machines, NICs, disks, extensions, Run Command, and SQL VM registration in the target scope. The module declares no provider configuration blocks.

## Basic Usage

```hcl
module "sqlvm" {
  source = "./modules/sqlvm"

  resource_group_name = "rg-app-prod"
  subnet_id           = module.subnet.ids["sql"]
  admin_username      = var.sql_admin_username
  admin_password      = var.sql_admin_password
}
```

The complete executable configuration is in [`examples/basic`](examples/basic/).

## Important Behavior and Secure Defaults

- The default SQL Server image is SQL Server 2022 Standard on Windows Server 2022, and SQL IaaS registration is enabled with `PAYG` licensing. Confirm image entitlement and choose `AHUB` only when eligible.
- Three managed disks are created per VM by default: data on LUN 0, log on LUN 1, and TempDB on LUN 2. Disk changes can affect cost, throughput, and replacement behavior.
- `admin_password` is sensitive and ignored for drift on the VM resource. Rotate it through an approved guest or platform process.
- `zones` and `availability_set_id` are mutually exclusive. Explicit VM names, private addresses, and zones must match the requested VM count where applicable.
- A Run Command resource is replaced when `run_command_replace_trigger` changes. Treat scripts as privileged code and use a content hash for deterministic reruns.
- Automatic patching, assessment, and backup are not enabled unless their configuration objects are supplied.

## Networking and Private Connectivity

The module creates private NICs only and does not create public IP addresses, an NSG, routes, or DNS. The supplied subnet must provide the required management, domain, update, and SQL client paths. Static addresses must belong to that subnet and are assigned in VM index order.

## Identity and RBAC

An identity block is optional. The module does not create role assignments for that identity. Callers must grant only the control-plane or data-plane roles required by guest bootstrap, backup, Key Vault, monitoring, or other integrations.

Domain join credentials are passed to the protected settings of `JsonADDomainExtension`. SQL connectivity and WSFC credentials can also be sensitive and must originate from a secret store.

## Naming and Tagging

Set `vm_names` explicitly or allow the module to generate names from the prefix, workload, location code, environment, and instance number. Windows computer names are normalized to 15 characters. Caller tags override inherited resource-group tags. See the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Examples

- [`basic`](examples/basic/): one private SQL VM using the default disk layout
- [`complete`](examples/complete/): two zonal SQL VMs with static addresses and SQL storage tuning
- [`availability-set`](examples/availability-set/): two SQL VMs placed in an existing Availability Set

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider and runs five plan-only tests. It requires no Azure authentication, creates no resources, and incurs no cost.

```powershell
terraform -chdir=modules/sqlvm init -backend=false
terraform -chdir=modules/sqlvm test
```

## Known Limitations

- The module does not create a Windows Failover Cluster, SQL availability group, listener, load balancer, database, backup vault, monitoring agent, NSG, or route table.
- SQL IaaS configuration is applied independently to each VM; workload-level high availability must be composed and operated separately.
- Plan-only mocked tests cannot prove image availability, domain reachability, licensing eligibility, extension execution, or guest SQL configuration.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_mssql_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_machine) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_virtual_machine_data_disk_attachment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.domain_join](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_run_command.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_run_command) | resource |
| [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [terraform_data.run_command_replace_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Local administrator password for SQL VMs. | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Local administrator username for SQL VMs. | `string` | n/a | yes |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for generated naming. | `string` | `"dev"` | no |
| <a name="input_assessment"></a> [assessment](#input\_assessment) | Optional SQL best practices assessment configuration. | <pre>object({<br>    enabled         = optional(bool)<br>    run_immediately = optional(bool)<br>    schedule = optional(object({<br>      day_of_week        = string<br>      monthly_occurrence = optional(number)<br>      start_time         = string<br>      weekly_interval    = optional(number)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_auto_backup"></a> [auto\_backup](#input\_auto\_backup) | Optional SQL Server automated backup configuration. | <pre>object({<br>    retention_period_in_days        = number<br>    storage_account_access_key      = string<br>    storage_blob_endpoint           = string<br>    system_databases_backup_enabled = optional(bool)<br>    encryption_password             = optional(string)<br>    manual_schedule = optional(object({<br>      days_of_week                    = optional(set(string))<br>      full_backup_frequency           = string<br>      full_backup_start_hour          = number<br>      full_backup_window_in_hours     = number<br>      log_backup_frequency_in_minutes = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_auto_patching"></a> [auto\_patching](#input\_auto\_patching) | Optional SQL Server auto patching configuration. | <pre>object({<br>    day_of_week                            = string<br>    maintenance_window_duration_in_minutes = number<br>    maintenance_window_starting_hour       = number<br>  })</pre> | `null` | no |
| <a name="input_availability_set_id"></a> [availability\_set\_id](#input\_availability\_set\_id) | Optional Availability Set ID. Do not set with zones. | `string` | `null` | no |
| <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks) | Managed data disks attached to each SQL VM. LUNs should align with storage\_configuration luns when SQL storage configuration is enabled. | <pre>map(object({<br>    lun                  = number<br>    disk_size_gb         = number<br>    storage_account_type = optional(string, "Premium_LRS")<br>    caching              = optional(string, "None")<br>    disk_iops_read_write = optional(number)<br>    disk_mbps_read_write = optional(number)<br>  }))</pre> | <pre>{<br>  "data01": {<br>    "caching": "ReadOnly",<br>    "disk_size_gb": 256,<br>    "lun": 0<br>  },<br>  "log01": {<br>    "caching": "None",<br>    "disk_size_gb": 128,<br>    "lun": 1<br>  },<br>  "tempdb01": {<br>    "caching": "ReadOnly",<br>    "disk_size_gb": 64,<br>    "lun": 2<br>  }<br>}</pre> | no |
| <a name="input_domain_join_options"></a> [domain\_join\_options](#input\_domain\_join\_options) | JsonADDomainExtension join options. | `number` | `3` | no |
| <a name="input_domain_join_password"></a> [domain\_join\_password](#input\_domain\_join\_password) | Domain join password used when enable\_domain\_join is true. | `string` | `""` | no |
| <a name="input_domain_join_restart"></a> [domain\_join\_restart](#input\_domain\_join\_restart) | Whether the domain join extension restarts the VM. | `bool` | `false` | no |
| <a name="input_domain_join_user"></a> [domain\_join\_user](#input\_domain\_join\_user) | Domain join username used when enable\_domain\_join is true. | `string` | `""` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Active Directory domain name used when enable\_domain\_join is true. | `string` | `""` | no |
| <a name="input_domain_ou_path"></a> [domain\_ou\_path](#input\_domain\_ou\_path) | Optional OU path used by JsonADDomainExtension. | `string` | `""` | no |
| <a name="input_enable_domain_join"></a> [enable\_domain\_join](#input\_enable\_domain\_join) | Whether to join SQL VMs to an Active Directory domain using JsonADDomainExtension. | `bool` | `false` | no |
| <a name="input_enable_sql_iaas_extension"></a> [enable\_sql\_iaas\_extension](#input\_enable\_sql\_iaas\_extension) | Whether to register each VM as an Azure SQL VM using azurerm\_mssql\_virtual\_machine. | `bool` | `true` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Optional managed identity block for SQL VMs. | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | <pre>{<br>  "type": "SystemAssigned"<br>}</pre> | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into SQL VM resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module reads the resource group. | `map(string)` | `null` | no |
| <a name="input_instance_start"></a> [instance\_start](#input\_instance\_start) | Starting numeric instance used when names are generated. | `number` | `1` | no |
| <a name="input_key_vault_credential"></a> [key\_vault\_credential](#input\_key\_vault\_credential) | Optional SQL VM key vault credential configuration. | <pre>object({<br>    name                     = string<br>    key_vault_url            = string<br>    service_principal_name   = string<br>    service_principal_secret = string<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region. Leave empty to read the target resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when names are generated. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when VM names are generated. Generated SQL VM names are capped at 15 characters for Windows computer name compatibility. | `string` | `"sql"` | no |
| <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk) | OS disk settings. | <pre>object({<br>    caching              = optional(string, "ReadWrite")<br>    storage_account_type = optional(string, "Premium_LRS")<br>    disk_size_gb         = optional(number, 128)<br>  })</pre> | `{}` | no |
| <a name="input_patch_assessment_mode"></a> [patch\_assessment\_mode](#input\_patch\_assessment\_mode) | Windows VM patch assessment mode. | `string` | `"AutomaticByPlatform"` | no |
| <a name="input_patch_mode"></a> [patch\_mode](#input\_patch\_mode) | Windows VM patch mode. | `string` | `"AutomaticByPlatform"` | no |
| <a name="input_private_ip_addresses"></a> [private\_ip\_addresses](#input\_private\_ip\_addresses) | Optional static private IP addresses, one per SQL VM. Leave empty for dynamic allocation. | `list(string)` | `[]` | no |
| <a name="input_r_services_enabled"></a> [r\_services\_enabled](#input\_r\_services\_enabled) | Whether SQL Server Machine Learning Services / R Services are enabled in SQL VM registration. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where SQL VMs are deployed. | `string` | n/a | yes |
| <a name="input_run_command"></a> [run\_command](#input\_run\_command) | Optional VM Run Command executed on each SQL VM after creation/domain join. | <pre>object({<br>    name   = optional(string, "RunCommandInit")<br>    script = string<br>  })</pre> | `null` | no |
| <a name="input_run_command_replace_trigger"></a> [run\_command\_replace\_trigger](#input\_run\_command\_replace\_trigger) | Arbitrary value used to force replacement of the Run Command resource when changed. | `any` | `null` | no |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | Source image reference for the SQL VM. Defaults to SQL Server 2022 Standard on Windows Server 2022 Gen2. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | <pre>{<br>  "offer": "sql2022-ws2022",<br>  "publisher": "MicrosoftSQLServer",<br>  "sku": "standard-gen2",<br>  "version": "latest"<br>}</pre> | no |
| <a name="input_sql_connectivity"></a> [sql\_connectivity](#input\_sql\_connectivity) | SQL connectivity settings for Azure SQL VM registration. | <pre>object({<br>    type            = optional(string, "PRIVATE")<br>    port            = optional(number, 1433)<br>    update_username = optional(string)<br>    update_password = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_sql_instance"></a> [sql\_instance](#input\_sql\_instance) | Optional SQL Server instance settings managed through SQL IaaS extension. | <pre>object({<br>    adhoc_workloads_optimization_enabled = optional(bool)<br>    collation                            = optional(string)<br>    instant_file_initialization_enabled  = optional(bool)<br>    lock_pages_in_memory_enabled         = optional(bool)<br>    max_dop                              = optional(number)<br>    max_server_memory_mb                 = optional(number)<br>    min_server_memory_mb                 = optional(number)<br>  })</pre> | `null` | no |
| <a name="input_sql_license_type"></a> [sql\_license\_type](#input\_sql\_license\_type) | SQL Server license type for Azure SQL VM registration. | `string` | `"PAYG"` | no |
| <a name="input_sql_virtual_machine_group_id"></a> [sql\_virtual\_machine\_group\_id](#input\_sql\_virtual\_machine\_group\_id) | Optional SQL virtual machine group ID for availability group scenarios. | `string` | `null` | no |
| <a name="input_storage_configuration"></a> [storage\_configuration](#input\_storage\_configuration) | Optional SQL storage configuration for data, log, and tempdb paths and LUNs. | <pre>object({<br>    disk_type                      = string<br>    storage_workload_type          = string<br>    system_db_on_data_disk_enabled = optional(bool)<br>    data_settings = optional(object({<br>      default_file_path = string<br>      luns              = list(number)<br>    }))<br>    log_settings = optional(object({<br>      default_file_path = string<br>      luns              = list(number)<br>    }))<br>    temp_db_settings = optional(object({<br>      default_file_path      = string<br>      luns                   = list(number)<br>      data_file_count        = optional(number)<br>      data_file_size_mb      = optional(number)<br>      data_file_growth_in_mb = optional(number)<br>      log_file_size_mb       = optional(number)<br>      log_file_growth_mb     = optional(number)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet resource ID for SQL VM NICs. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for SQL VM resources. | `map(string)` | `{}` | no |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | Number of SQL VMs to deploy. | `number` | `1` | no |
| <a name="input_vm_names"></a> [vm\_names](#input\_vm\_names) | Optional explicit SQL VM names. Leave empty to generate names from name\_prefix, workload, location, environment, and instance. | `list(string)` | `[]` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size for SQL Server. | `string` | `"Standard_E8ds_v5"` | no |
| <a name="input_windows_license_type"></a> [windows\_license\_type](#input\_windows\_license\_type) | Optional Windows license type, commonly Windows\_Server when using Azure Hybrid Benefit. | `string` | `null` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Deprecated compatibility input. Supply workload\_name or workload tags explicitly where possible. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when names are generated. | `string` | `""` | no |
| <a name="input_wsfc_domain_credential"></a> [wsfc\_domain\_credential](#input\_wsfc\_domain\_credential) | Optional WSFC domain credential passwords used with SQL VM group scenarios. | <pre>object({<br>    cluster_bootstrap_account_password = string<br>    cluster_operator_account_password  = string<br>    sql_service_account_password       = string<br>  })</pre> | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Optional availability zones. Values are distributed across VMs by index. Do not set with availability\_set\_id. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_computer_names"></a> [computer\_names](#output\_computer\_names) | Map of Windows computer names by instance key. |
| <a name="output_ids"></a> [ids](#output\_ids) | Map of SQL VM Azure VM resource IDs by instance key. |
| <a name="output_location"></a> [location](#output\_location) | Resolved Azure region. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | Short location code used for generated naming. |
| <a name="output_managed_disk_ids"></a> [managed\_disk\_ids](#output\_managed\_disk\_ids) | Map of managed data disk IDs by compound key '<vm\_index>\|<disk\_key>'. |
| <a name="output_names"></a> [names](#output\_names) | Map of SQL VM names by instance key. |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | Map of NIC IDs by instance key. |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | Map of private IP addresses by instance key. |
| <a name="output_sql_virtual_machine_ids"></a> [sql\_virtual\_machine\_ids](#output\_sql\_virtual\_machine\_ids) | Map of Azure SQL VM registration IDs by instance key. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to SQL VM resources. |
<!-- END_TF_DOCS -->
