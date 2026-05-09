provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "prod"

  features {}
}

provider "azuread" {}

variables {
  module_plan_enabled = {
    acr                  = false
    adf                  = false
    aks                  = false
    appregistration      = false
    appservice           = false
    appserviceplan       = false
    applicationgateway   = false
    automationaccount    = false
    azure_ai_service     = false
    databricks           = false
    eventhub             = false
    firewall             = true
    functionapp          = false
    keyvault             = false
    linuxvm              = false
    loganalytics         = true
    logicapp             = false
    managedidentity      = true
    managementgroups     = true
    nsg                  = true
    openai               = false
    policy               = true
    private_dns          = true
    rg                   = false
    roleassignments      = false
    route_table          = true
    servicebus           = false
    sqldb                = false
    sqlmi                = false
    sqlmi_db             = false
    storageaccount       = false
    subscription_vending = true
    vnet                 = false
    winvm                = false
  }

  subscription_id                 = ""
  tenant_id                       = ""
  location                        = "eastus"
  environment                     = "dev"
  workload                        = "platform"
  shared_resource_group_name      = "rg-platform-dev"
  network_resource_group_name     = "rg-platform-dev-network"
  private_dns_resource_group_name = "rg-platform-dev-dns"
  shared_vnet_name                = "vnet-platform-dev"
  app_subnet_name                 = "snet-app"
  private_endpoint_subnet_name    = "snet-private-endpoints"
  firewall_subnet_name            = "AzureFirewallSubnet"
  shared_storage_account_name     = "stplatformeusdev"
  shared_key_vault_name           = "kvplatformeusdev"
  shared_log_analytics_name       = "law-platform-dev"
  shared_app_service_plan_name    = "asp-platform-dev"
  shared_vm_name                  = "vmplatformdev"
  shared_management_group_name    = "mg-platform-dev"
  sample_principal_object_id      = "00000000-0000-0000-0000-000000000001"
  app_admin_group                 = []
  app_user_group                  = []
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "module-plan-harness"
    Workload    = "platform"
  }
}

run "plan_root_harness" {
  command = plan

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
    azuread      = azuread
  }
}
