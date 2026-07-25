# SQL VM Module Complete

The `sqlvm` module provides a reusable SQL Server on Azure VM deployment pattern aligned to the template repository module standards.

Implemented resources:

- `azurerm_network_interface`
- `azurerm_windows_virtual_machine`
- `azurerm_managed_disk`
- `azurerm_virtual_machine_data_disk_attachment`
- `azurerm_virtual_machine_extension` for optional domain join
- `azurerm_virtual_machine_run_command` for optional bootstrap
- `azurerm_mssql_virtual_machine` for SQL IaaS registration

Validation completed:

- `terraform fmt -recursive`
- `terraform init -backend=false`
- `terraform validate`
- `terraform test`
