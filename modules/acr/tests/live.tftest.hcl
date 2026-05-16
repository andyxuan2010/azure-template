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
  resource_group_name = "rg-ba-eus-prd-shared-management"
  location            = "eastus"
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
    condition     = output.name == "acreusacriactestprod001prod001"
    error_message = "ACR generated name did not match the expected naming convention."
  }

  assert {
    condition     = output.tags.module == "acr"
    error_message = "ACR tags did not include the module marker."
  }

  assert {
    condition     = output.private_endpoint_id == null
    error_message = "ACR private endpoint should not be created in the base live test."
  }
}

run "plan_hardened" {
  command = plan

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
    azuread      = azuread
  }

  variables {
    resource_group_name = "rg-ba-eus-prd-shared-management"
    location            = "eastus"
    name                = "acriactestprod001"
    app_env             = "prod"
    sku                 = "Premium"

    public_network_access_enabled     = false
    export_policy_enabled             = false
    quarantine_policy_enabled         = true
    retention_policy_in_days          = 14
    trust_policy_enabled              = true
    zone_redundancy_enabled           = true
    identity_type                     = "SystemAssigned"
    managed_identity_role_assignments = {}

    georeplications = [
      {
        location                  = "westus2"
        regional_endpoint_enabled = true
        zone_redundancy_enabled   = false
        tags = {
          Role = "secondary"
        }
      }
    ]

    app_admin_group = []
    app_user_group  = []

    enable_network_rule_set     = true
    network_rule_default_action = "Deny"
    network_rule_ip_rules       = ["203.0.113.10/32"]

    enable_private_endpoint = false
    enable_diagnostics      = false

    diagnostic_log_categories    = ["ContainerRegistryRepositoryEvents"]
    diagnostic_metric_categories = ["AllMetrics"]

    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.location == var.location
    error_message = "ACR location output did not match the requested location."
  }

  assert {
    condition     = output.managed_identity_role_assignment_ids == {}
    error_message = "Managed identity role assignments should be empty when none are requested."
  }
}
