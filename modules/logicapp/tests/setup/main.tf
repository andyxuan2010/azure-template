terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku_name" {
  type = string
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = "${var.resource_group_name}-${random_string.suffix.result}"
  location = var.location
}

resource "azurerm_service_plan" "this" {
  name                = "asp-logic-iactest-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  os_type             = "Windows"
  sku_name            = var.sku_name

  worker_count = 1
}

resource "azurerm_storage_account" "this" {
  name                     = "stlogic${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "service_plan_id" {
  value = azurerm_service_plan.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "logic_app_name" {
  value = "logic-iactest-${random_string.suffix.result}"
}
