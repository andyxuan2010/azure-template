provider "azurerm" {
  features {}
}

variables {
  resource_group_name                          = "rg-ba-eus-prd-shared-management"
  location                                     = "eastus"
  name                                         = "aa-iactest-prod-001"
  public_access_enabled                        = true
  system_managed_identity_enabled              = false
  app_admin_group                              = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group                               = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  managed_identity_role_assignments            = {}
  private_endpoint_subnet_id                   = ""
  private_endpoint_subnet_name                 = ""
  private_endpoint_vnet_name                   = ""
  private_endpoint_network_resource_group_name = ""
  pep_vnet_name                                = ""
  pep_vnet_resource_group_name                 = ""
  private_endpoint_vnet_exceptions             = []
  enable_webhook_private_endpoint              = false
  enable_hrw_private_endpoint                  = false
  private_dns_zone_id                          = ""
  enable_diagnostics                           = false
  tags                                         = {}
}

run "apply" {
  command = apply
}
