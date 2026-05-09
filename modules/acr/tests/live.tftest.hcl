# modules/acr/tests/live.tftest.hcl
provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "prod"

  features {}
}

provider "azuread" {}

variables {
  # resource_group_name = "rg-test-shared"
  # location            = "eastus"
  # name                = "acrtestmodule001"
  # app_admin_group     = ["11111111-1111-1111-1111-111111111111", "Test-Admins"]
  # app_user_group      = ["22222222-2222-2222-2222-222222222222", "Test-Users"]

  resource_group_name = "rg-ba-eus-prd-shared-management"
  location            = "eastus"
  name                = "acriactestprod001"

  sku                             = "Premium"
  admin_enabled                   = false
  public_network_access_enabled   = false
  anonymous_pull_enabled          = false
  data_endpoint_enabled           = false
  system_managed_identity_enabled = false

  # Optional ACR RBAC groups.
  # Leave as [] to skip group-based role assignments.
  # If a display name is duplicated in Entra ID, use the group's object ID instead.
  app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]

  # Premium SKU ACR network rules.
  enable_network_rule_set     = false
  network_rule_bypass_option  = "AzureServices"
  network_rule_default_action = "Deny"
  network_rule_ip_rules       = []

  enable_private_endpoint                      = false
  private_endpoint_subnet_id                   = ""
  private_endpoint_subnet_name                 = ""
  private_endpoint_vnet_name                   = ""
  private_endpoint_network_resource_group_name = ""
  private_dns_zone_id                          = ""
  private_dns_zone_name                        = ""
  private_dns_zone_resource_group_name         = ""

  enable_diagnostics = false
  # Optional override: leave commented to use data.azurerm_log_analytics_workspace.this.id.
  # log_analytics_workspace_id = "<log-analytics-workspace-resource-id>"
  diagnostic_log_categories    = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]
  diagnostic_metric_categories = ["AllMetrics"]

  tags = {
    "Environment" = "Production"
    "Owner"       = "CCOE"
    "IaC"         = "Terraform"
  }
}

run "apply" {
  command = apply

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
    azuread      = azuread
  }
}
