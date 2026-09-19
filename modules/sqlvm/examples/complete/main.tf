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

  resource_group_name  = var.resource_group_name
  location             = var.location
  workload_name        = var.workload_name
  app_env              = var.app_env
  vm_count             = 2
  vm_names             = var.vm_names
  subnet_id            = var.subnet_id
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  private_ip_addresses = var.private_ip_addresses
  zones                = ["1", "2"]
  sql_license_type     = "AHUB"

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

  assessment = {
    enabled = true
  }

  tags = var.tags
}
