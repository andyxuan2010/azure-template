# Unit tests: mocked providers, plan-only. No cloud authentication and no cloud resources.

mock_provider "azurerm" {}

mock_provider "azurerm" {
  alias = "prod"
}

mock_provider "azuread" {}

variables {
  resource_group_name = "rg-ccoe-iac-cc-dev"
  location            = "canadacentral"
  name                = "acriactestprod001"
  app_env             = "prod"

  sku                               = "Premium"
  admin_enabled                     = false
  public_network_access_enabled     = false
  anonymous_pull_enabled            = false
  data_endpoint_enabled             = false
  export_policy_enabled             = true
  quarantine_policy_enabled         = false
  retention_policy_in_days          = 7
  trust_policy_enabled              = false
  zone_redundancy_enabled           = false
  identity_type                     = "None"
  identity_ids                      = []
  managed_identity_role_assignments = {}

  app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]

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

  enable_diagnostics           = false
  log_analytics_workspace_id   = ""
  diagnostic_log_categories    = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]
  diagnostic_metric_categories = ["AllMetrics"]

  tags = {
    "Environment" = "Production"
    "Owner"       = "CCOE"
    "IaC"         = "Terraform"
  }
}

run "plan" {
  command = plan

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
    azuread      = azuread
  }

  assert {
    condition     = output.name == "acriactestprod001"
    error_message = "ACR explicit name override was not preserved."
  }

  assert {
    condition     = !contains(keys(output.tags), "module") && !contains(keys(output.tags), "ManagedBy") && !contains(keys(output.tags), "name")
    error_message = "ACR tags should not include module-generated ManagedBy, module, or name tags."
  }

  assert {
    condition     = output.private_endpoint_id == null
    error_message = "ACR private endpoint should not be created when enable_private_endpoint is false."
  }
}
