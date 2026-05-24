provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  name                           = "sqlmi-iactest-prod-001"
  resource_group_name            = "rg-ba-cc-prd-shared-management"
  location                       = "canadacentral"
  subnet_id                      = "/subscriptions/ef8ff35a-8548-485c-be32-204db0340dd1/resourceGroups/rg-ba-cc-prod-app-network/providers/Microsoft.Network/virtualNetworks/vnet-ba-cc-prod-app/subnets/snet-ba-cc-prod-app-datatier-mi"
  administrator_login            = "sqladminuser"
  administrator_login_password   = "TerraformLiveTest-ChangeMe1234!"
  sku_name                       = "GP_Gen5"
  license_type                   = "BasePrice"
  vcores                         = 8
  storage_size_in_gb             = 512
  collation                      = "SQL_Latin1_General_CP1_CI_AS"
  minimum_tls_version            = "1.2"
  timezone_id                    = "UTC"
  public_data_endpoint_enabled   = false
  proxy_override                 = "Proxy"
  storage_account_type           = "GRS"
  maintenance_configuration_name = "SQL_Default"
  zone_redundant_enabled         = false
  dns_zone_partner_id            = ""
  identity_type                  = "SystemAssigned"
  identity_ids                   = []
  app_admin_group                = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group                 = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  azure_active_directory_administrator = {
    login_username                      = "BA-G-Azure-Owner-F"
    object_id                           = "7a958d36-a182-451e-8012-4e8fe9386dc7"
    principal_type                      = "Group"
    tenant_id                           = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
    azuread_authentication_only_enabled = false
  }
  enable_diagnostics = false
  tags = {
    resourceType = "SQLMI"
  }
}

run "apply" {
  command = apply
}
