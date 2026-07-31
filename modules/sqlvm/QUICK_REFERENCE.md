# SQL VM Quick Reference

## Minimal

```hcl
module "sqlvm" {
  source = "git::https://dev.azure.com/Bombardier-Enterprise/CCoE-Infra-IaC/_git/template//modules/sqlvm"

  resource_group_name = "rg-app-prod"
  location            = "canadacentral"
  subnet_id           = module.subnets.ids["snet-app-db-prod"]
  admin_username      = var.sql_admin_username
  admin_password      = var.sql_admin_password
}
```

## Common Production Inputs

```hcl
vm_count             = 2
vm_size              = "Standard_E8ds_v5"
vm_names             = ["sqlappccprod001", "sqlappccprod002"]
private_ip_addresses = ["10.67.76.100", "10.67.76.101"]
zones                = ["1", "2"]
sql_license_type     = "AHUB"
```

## Defaults

- `vm_count`: `1`
- `vm_size`: `Standard_E8ds_v5`
- `enable_sql_iaas_extension`: `true`
- `sql_license_type`: `PAYG`
- SQL image: SQL Server 2022 Standard on Windows Server 2022 Gen2
- Disks per VM: data, log, tempdb

## Outputs

- `ids`
- `names`
- `network_interface_ids`
- `private_ip_addresses`
- `managed_disk_ids`
- `sql_virtual_machine_ids`
