terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
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

module "servicebus" {
  source = "../.."

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.name
  sku                 = "Standard"

  local_auth_enabled          = false
  inherit_resource_group_tags = false

  topics = {
    order_events = {
      support_ordering = true
    }
  }

  subscriptions = {
    billing = {
      topic_name                           = "order_events"
      dead_lettering_on_message_expiration = true
    }
    fulfillment = {
      topic_name                           = "order_events"
      dead_lettering_on_message_expiration = true
    }
  }

  tags = var.tags
}
