terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "scheduled_automation" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}
  local_auth_enabled            = false
  public_access_enabled         = false

  runbooks = {
    inventory = {
      name         = "rb-resource-inventory"
      runbook_type = "PowerShell72"
      description  = "Emits an execution timestamp; replace with reviewed operational logic."
      content      = <<-POWERSHELL
        param(
          [string] $Environment = "dev"
        )

        Write-Output "Inventory run for $Environment at $(Get-Date -Format o)"
      POWERSHELL
    }
  }

  schedules = {
    daily = {
      name        = "sched-inventory-daily"
      frequency   = "Day"
      interval    = 1
      timezone    = "Etc/UTC"
      start_time  = var.schedule_start_time
      description = "Daily inventory schedule."
    }
  }

  job_schedules = {
    inventory_daily = {
      runbook_name  = "inventory"
      schedule_name = "daily"
      parameters = {
        environment = var.environment
      }
    }
  }

  string_variables = {
    environment = {
      name        = "Environment"
      value       = var.environment
      description = "Environment processed by operational runbooks."
    }
  }

  int_variables = {
    retry_count = {
      name        = "RetryCount"
      value       = 3
      description = "Default retry count for runbooks."
    }
  }
}
