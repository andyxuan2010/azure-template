provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name                          = "rg-ba-eus-prd-shared-management"
  location                                     = "eastus"
  name                                         = "ais-iactest-prod-001"
  sku_name                                     = "S0"
  custom_subdomain_name                        = ""
  public_network_access_enabled                = true
  outbound_network_access_restricted           = false
  local_auth_enabled                           = true
  dynamic_throttling_enabled                   = false
  fqdns                                        = []
  project_management_enabled                   = false
  identity                                     = null
  customer_managed_key                         = null
  storage                                      = []
  network_acls                                 = null
  enable_private_endpoint                      = false
  private_endpoint_subnet_id                   = ""
  private_endpoint_subnet_name                 = ""
  private_endpoint_vnet_name                   = ""
  private_endpoint_network_resource_group_name = ""
  private_dns_zone_id                          = ""
  app_admin_group                              = []
  app_user_group                               = []
  enable_diagnostics                           = false
  log_analytics_workspace_id                   = ""
  diagnostic_log_categories                    = []
  diagnostic_metric_categories                 = ["AllMetrics"]
  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "plan" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Azure AI Services account test name was not propagated to the module."
  }

  assert {
    condition     = output.merged_tags.module == "azure_ai_service"
    error_message = "Azure AI Services merged tags did not include the module marker."
  }
}

run "plan_private_endpoint_defaults" {
  command = plan

  variables {
    resource_group_name                          = "rg-ba-eus-prd-shared-management"
    location                                     = "eastus"
    name                                         = "ais-iactest-prod-001"
    sku_name                                     = "S0"
    custom_subdomain_name                        = ""
    public_network_access_enabled                = false
    outbound_network_access_restricted           = false
    local_auth_enabled                           = true
    dynamic_throttling_enabled                   = false
    fqdns                                        = []
    project_management_enabled                   = false
    identity                                     = null
    customer_managed_key                         = null
    storage                                      = []
    network_acls                                 = null
    enable_private_endpoint                      = true
    private_endpoint_subnet_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_endpoint_subnet_name                 = ""
    private_endpoint_vnet_name                   = ""
    private_endpoint_network_resource_group_name = ""
    private_dns_zone_id                          = ""
    private_dns_zone_ids                         = []
    app_admin_group                              = []
    app_user_group                               = []
    enable_diagnostics                           = false
    log_analytics_workspace_id                   = ""
    diagnostic_log_categories                    = []
    diagnostic_metric_categories                 = ["AllMetrics"]
    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.custom_subdomain_name == var.name
    error_message = "Azure AI Services custom_subdomain_name should default to the account name when a private endpoint is enabled."
  }
}
