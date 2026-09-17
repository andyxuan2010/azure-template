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

  sku                          = "Premium"
  capacity                     = 1
  premium_messaging_partitions = 1

  local_auth_enabled              = false
  public_network_access_enabled   = false
  system_managed_identity_enabled = true
  enable_network_rule_set         = true
  network_rule_default_action     = "Deny"
  trusted_services_allowed        = false

  queues = {
    commands = {
      requires_duplicate_detection            = true
      duplicate_detection_history_time_window = "PT10M"
      dead_lettering_on_message_expiration    = true
    }
  }

  topics = {
    domain_events = {
      support_ordering             = true
      requires_duplicate_detection = true
    }
  }

  subscriptions = {
    analytics = {
      topic_name                           = "domain_events"
      dead_lettering_on_message_expiration = true
    }
  }

  enable_private_endpoint    = true
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_id        = var.private_dns_zone_id

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  app_admin_group = var.app_admin_group_object_ids
  app_user_group  = var.app_user_group_object_ids

  inherit_resource_group_tags = false
  tags                        = var.tags
}
