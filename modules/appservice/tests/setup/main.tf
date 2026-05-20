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

variable "os_type" {
  type = string
}

variable "sku_name" {
  type = string
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_service_plan" "this" {
  name                = "asp-iactest-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name

  worker_count = 1
}

output "service_plan_id" {
  value = azurerm_service_plan.this.id
}

output "app_name" {
  value = "app-iactest-${random_string.suffix.result}"
}
