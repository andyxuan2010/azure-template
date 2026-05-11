provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "prod"

  features {}
}

provider "azuread" {}

variables {
  resource_group_name                          = "rg-ba-eus-prd-shared-management"
  location                                     = "eastus"
  tenant_id                                    = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
  name                                         = "kviactestprod001"
  sku_name                                     = "standard"
  enable_rbac_authorization                    = true
  public_network_access_enabled                = false
  purge_protection_enabled                     = false
  soft_delete_retention_days                   = 90
  enabled_for_deployment                       = false
  enabled_for_disk_encryption                  = false
  enabled_for_template_deployment              = false
  app_admin_group                              = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group                               = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  enable_network_acls                          = false
  network_acls_default_action                  = "Deny"
  network_acls_bypass                          = "AzureServices"
  network_acls_ip_rules                        = []
  network_acls_virtual_network_subnet_ids      = []
  enable_private_endpoint                      = false
  private_endpoint_subnet_id                   = ""
  private_endpoint_subnet_name                 = ""
  private_endpoint_vnet_name                   = ""
  private_endpoint_network_resource_group_name = ""
  private_dns_zone_id                          = ""
  private_dns_zone_name                        = null
  private_dns_zone_resource_group_name         = null
  enable_diagnostics                           = false
  diagnostic_log_categories                    = ["AuditEvent"]
  diagnostic_metric_categories                 = ["AllMetrics"]
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
}
