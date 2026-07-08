# SQL VM Module

Deploys one or more Windows SQL Server virtual machines and registers them with the Azure SQL IaaS extension.

The module is intended for workloads that need full SQL Server on Azure VMs rather than Azure SQL Database or SQL Managed Instance. It creates NICs, Windows VMs, managed data disks, disk attachments, optional domain join, optional VM Run Command, and optional `azurerm_mssql_virtual_machine` configuration.

## Features

- Multiple SQL VMs from one module call.
- Explicit or generated Windows-compatible VM names.
- Static or dynamic private IPs.
- Availability Zones or Availability Set placement.
- Default data, log, and tempdb managed disks.
- SQL IaaS registration with license type, connectivity, storage, assessment, backup, and patching options.
- Optional Active Directory domain join.
- Optional VM Run Command bootstrap.
- Resource group tag inheritance.

## Basic Usage

```hcl
module "sqlvm" {
  source = "git::https://dev.azure.com/Bombardier-Enterprise/CCoE-Infra-IaC/_git/template//modules/sqlvm"

  resource_group_name = "rg-app-prod"
  location            = "canadacentral"
  workload_name       = "app"
  app_env             = "prod"
  vm_count            = 2
  vm_names            = ["sqlappccprod001", "sqlappccprod002"]
  subnet_id           = module.subnet.ids["snet-app-sql-prod"]

  admin_username = var.sql_admin_username
  admin_password = var.sql_admin_password

  private_ip_addresses = [
    "10.67.76.100",
    "10.67.76.101",
  ]

  zones            = ["1", "2"]
  sql_license_type = "AHUB"
}
```

## SQL Storage Configuration

The module creates three managed disks per VM by default:

| Disk key | LUN | Intended use | Default caching |
| --- | ---: | --- | --- |
| `data01` | `0` | SQL data files | `ReadOnly` |
| `log01` | `1` | SQL transaction logs | `None` |
| `tempdb01` | `2` | TempDB | `ReadOnly` |

Pass `storage_configuration` when you want the SQL IaaS extension to configure SQL file paths against those LUNs.

```hcl
storage_configuration = {
  disk_type             = "NEW"
  storage_workload_type = "OLTP"
  data_settings = {
    default_file_path = "F:\\SQLData"
    luns              = [0]
  }
  log_settings = {
    default_file_path = "G:\\SQLLog"
    luns              = [1]
  }
  temp_db_settings = {
    default_file_path = "T:\\TempDB"
    luns              = [2]
    data_file_count   = 4
  }
}
```

## High Availability

This module provisions SQL VMs and exposes the SQL VM registration controls needed for availability group scenarios, including `sql_virtual_machine_group_id` and `wsfc_domain_credential`. It does not create the Windows Failover Cluster, listener load balancer, or availability group database objects. Compose those separately so cluster lifecycle remains explicit.

Use either:

- `zones` for zone-spread VMs, or
- `availability_set_id` for an existing Availability Set.

Do not use both in the same module call.

## Important Inputs

| Input | Purpose |
| --- | --- |
| `vm_count` | Number of SQL VMs. |
| `vm_names` | Optional explicit VM names. Must match `vm_count` when set. |
| `subnet_id` | SQL subnet ID. |
| `admin_username`, `admin_password` | Local VM administrator credentials. Use pipeline or Key Vault sourced values at root. |
| `data_disks` | Managed disk definition applied to every VM. |
| `enable_sql_iaas_extension` | Registers each VM as an Azure SQL VM. Defaults to `true`. |
| `sql_license_type` | `PAYG`, `AHUB`, or `DR`. |
| `storage_configuration` | SQL IaaS storage layout for data/log/tempdb. |
| `enable_domain_join` | Adds the JsonADDomainExtension. |
| `run_command` | Optional bootstrap command after VM creation/domain join. |

## Outputs

| Output | Description |
| --- | --- |
| `ids` | Azure VM IDs by instance key. |
| `names` | VM names by instance key. |
| `network_interface_ids` | NIC IDs by instance key. |
| `private_ip_addresses` | NIC private IPs by instance key. |
| `managed_disk_ids` | Data disk IDs by `<vm_index>|<disk_key>`. |
| `sql_virtual_machine_ids` | SQL VM registration IDs by instance key. |
