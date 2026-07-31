# SQL VM Examples

## Two SQL VMs for an application database tier

```hcl
module "sqlvm" {
  source = "git::https://dev.azure.com/Bombardier-Enterprise/CCoE-Infra-IaC/_git/template//modules/sqlvm"

  resource_group_name = local.app_resource_group_name
  location            = var.location
  workload_name       = var.workload
  app_env             = var.app_env
  vm_count            = 2
  vm_names            = ["sqlappccprod001", "sqlappccprod002"]
  subnet_id           = module.app_subnets.ids["snet-app-db-prod"]

  admin_username = var.sql_admin_username
  admin_password = var.sql_admin_password

  private_ip_addresses = [
    "10.67.76.100",
    "10.67.76.101",
  ]

  zones            = ["1", "2"]
  sql_license_type = "AHUB"

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
      default_file_path      = "T:\\TempDB"
      luns                   = [2]
      data_file_count        = 4
      data_file_size_mb      = 256
      data_file_growth_in_mb = 256
      log_file_size_mb       = 256
      log_file_growth_mb     = 128
    }
  }

  sql_instance = {
    instant_file_initialization_enabled = true
    lock_pages_in_memory_enabled        = true
    max_dop                             = 4
    max_server_memory_mb                = 24576
    min_server_memory_mb                = 4096
  }

  tags = local.rg_tags
}
```

## Domain-joined SQL VMs with bootstrap

```hcl
module "sqlvm" {
  source = "git::https://dev.azure.com/Bombardier-Enterprise/CCoE-Infra-IaC/_git/template//modules/sqlvm"

  resource_group_name = local.app_resource_group_name
  location            = var.location
  workload_name       = "platform"
  app_env             = "prod"
  vm_count            = 2
  subnet_id           = module.subnets.ids["snet-platform-db-prod"]

  admin_username = var.sql_admin_username
  admin_password = var.sql_admin_password

  enable_domain_join   = true
  domain_name          = "corp.example.com"
  domain_join_user     = var.domain_join_user
  domain_join_password = var.domain_join_password

  run_command_replace_trigger = filemd5("${path.module}/scripts/sql-bootstrap.ps1")
  run_command = {
    name   = "SqlBootstrap"
    script = file("${path.module}/scripts/sql-bootstrap.ps1")
  }
}
```

## Availability Set placement

```hcl
module "sql_availability_set" {
  source = "git::https://dev.azure.com/Bombardier-Enterprise/CCoE-Infra-IaC/_git/template//modules/availabilityset"

  resource_group_name = local.app_resource_group_name
  location            = var.location
  workload_name       = var.workload
  app_env             = var.app_env
}

module "sqlvm" {
  source = "git::https://dev.azure.com/Bombardier-Enterprise/CCoE-Infra-IaC/_git/template//modules/sqlvm"

  resource_group_name  = local.app_resource_group_name
  location             = var.location
  subnet_id            = module.subnets.ids["snet-app-db-prod"]
  availability_set_id  = module.sql_availability_set.id
  vm_count             = 2
  admin_username       = var.sql_admin_username
  admin_password       = var.sql_admin_password
}
```
