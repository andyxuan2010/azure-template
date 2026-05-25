provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name          = "rg-ba-cc-prd-shared-management"
  location                     = "canadacentral"
  name                         = "sb${formatdate("MMDDhhmmss", timestamp())}001"
  sku                          = "Standard"
  capacity                     = 0
  premium_messaging_partitions = 0

  queues = {
    orders = {
      max_size_in_megabytes                = 1024
      max_delivery_count                   = 10
      lock_duration                        = "PT1M"
      default_message_ttl                  = "P14D"
      dead_lettering_on_message_expiration = true
      requires_duplicate_detection         = false
      requires_session                     = false
      partitioning_enabled                 = false
      express_enabled                      = false
      batched_operations_enabled           = true
      status                               = "Active"
    }
  }

  topics = {
    events = {
      max_size_in_megabytes        = 1024
      default_message_ttl          = "P14D"
      requires_duplicate_detection = false
      partitioning_enabled         = false
      express_enabled              = false
      batched_operations_enabled   = true
      support_ordering             = false
      status                       = "Active"
    }
  }

  subscriptions = {
    events_processor = {
      topic_name                                = "events"
      max_delivery_count                        = 10
      lock_duration                             = "PT1M"
      default_message_ttl                       = "P14D"
      dead_lettering_on_message_expiration      = true
      dead_lettering_on_filter_evaluation_error = false
      requires_session                          = false
      batched_operations_enabled                = true
      status                                    = "Active"
      client_scoped_subscription_enabled        = false
    }
  }

  authorization_rules = {
    sender = {
      send   = true
      listen = false
      manage = false
    }
  }

  enable_network_rule_set                      = false
  network_rule_default_action                  = "Allow"
  network_rule_ip_rules                        = []
  trusted_services_allowed                     = false
  network_rules                                = []
  app_admin_group                              = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group                               = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  enable_private_endpoint                      = false
  enable_diagnostics                           = false
  local_auth_enabled                           = true
  public_network_access_enabled                = true
  system_managed_identity_enabled              = false
  minimum_tls_version                          = "1.2"
  private_endpoint_subnet_id                   = ""
  private_endpoint_subnet_name                 = ""
  private_endpoint_vnet_name                   = ""
  private_endpoint_network_resource_group_name = ""
  private_dns_zone_id                          = ""
  log_analytics_workspace_id                   = ""
  diagnostic_log_categories                    = ["OperationalLogs"]
  diagnostic_metric_categories                 = ["AllMetrics"]
  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "apply" {
  command = apply

  assert {
    condition     = output.name == var.name
    error_message = "Service Bus namespace test name was not propagated to the module."
  }

  assert {
    condition     = !contains(keys(output.merged_tags), "module")
    error_message = "Service Bus merged tags should not include the module marker."
  }
}
