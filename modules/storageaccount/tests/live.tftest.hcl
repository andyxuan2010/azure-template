provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "prod"

  features {}
}

provider "azuread" {}

variables {
  resource_group_name                  = "rg-ba-eus-prd-shared-management"
  location                             = "eastus"
  name                                 = "stiactestprod001"
  default_to_oauth_authentication      = true
  system_managed_identity_enabled      = false
  managed_identity_role_assignments    = {}
  app_admin_group                      = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group                       = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  private_endpoint_subresource_names   = []
  private_dns_zone_ids                 = {}
  private_dns_zone_names               = {}
  private_dns_zone_resource_group_name = null
  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "apply" {
  command = apply

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
    azuread      = azuread
  }

  assert {
    condition     = output.name == var.name
    error_message = "Storage account test name was not propagated to the module."
  }

  assert {
    condition     = output.default_to_oauth_authentication == true
    error_message = "Storage account did not enable default_to_oauth_authentication as expected."
  }
}
