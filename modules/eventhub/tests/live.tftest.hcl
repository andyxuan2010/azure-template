provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name = "rg-ba-eus-prd-shared-management"
  location            = "eastus"
  name                = "evh${formatdate("MMDDhhmmss", timestamp())}001"
  sku                 = "Standard"
  capacity            = 1

  eventhubs = {
    telemetry = {
      partition_count   = 2
      message_retention = 1
      status            = "Active"
    }
  }

  authorization_rules = {
    sender = {
      send   = true
      listen = false
      manage = false
    }
  }

  app_admin_group                              = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group                               = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  enable_private_endpoint                      = false
  enable_diagnostics                           = false
  local_authentication_enabled                 = true
  public_network_access_enabled                = true
  system_managed_identity_enabled              = false
  auto_inflate_enabled                         = false
  maximum_throughput_units                     = 0
  minimum_tls_version                          = "1.2"
  private_endpoint_subnet_id                   = ""
  private_endpoint_subnet_name                 = ""
  private_endpoint_vnet_name                   = ""
  private_endpoint_network_resource_group_name = ""
  private_dns_zone_id                          = ""
  log_analytics_workspace_id                   = ""
  diagnostic_log_categories                    = ["ArchiveLogs"]
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
    error_message = "Event Hub namespace test name was not propagated to the module."
  }

  assert {
    condition     = output.merged_tags.module == "eventhub"
    error_message = "Event Hub merged tags did not include the module marker."
  }
}
