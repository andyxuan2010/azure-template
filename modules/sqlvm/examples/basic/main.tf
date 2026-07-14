terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "sqlvm" {
  source = "../.."

  resource_group_name = "rg-app-prod"
  location            = "canadacentral"
  workload_name       = "app"
  app_env             = "prod"
  vm_count            = 2
  vm_names            = ["sqlappccprod001", "sqlappccprod002"]
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-app/subnets/snet-app-sql-prod"

  admin_username = "azureadmin"
  admin_password = "Replace-With-KeyVault-Or-Pipeline-Secret-123!"

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

  tags = {
    Workload    = "app"
    Environment = "Production"
  }
}
