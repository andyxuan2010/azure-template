provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name                          = "rg-ba-eus-prd-shared-management"
  location                                     = "eastus"
  name                                         = "srch-iactest-prod-001"
  sku                                          = "standard"
  replica_count                                = 1
  partition_count                              = 1
  hosting_mode                                 = "default"
  semantic_search_sku                          = ""
  public_network_access_enabled                = true
  allowed_ips                                  = []
  network_rule_bypass_option                   = "None"
  local_authentication_enabled                 = true
  authentication_failure_mode                  = ""
  customer_managed_key_enforcement_enabled     = false
  identity                                     = null
  enable_private_endpoint                      = false
  private_endpoint_subnet_id                   = ""
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

run "plan" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Azure AI Search service test name was not propagated to the module."
  }

  assert {
    condition     = output.merged_tags.module == "azure_ai_search"
    error_message = "Azure AI Search merged tags did not include the module marker."
  }
}

run "plan_private_endpoint" {
  command = plan

  variables {
    resource_group_name                          = "rg-ba-eus-prd-shared-management"
    location                                     = "eastus"
    name                                         = "srch-iactest-prod-001"
    sku                                          = "standard"
    replica_count                                = 1
    partition_count                              = 1
    hosting_mode                                 = "default"
    semantic_search_sku                          = ""
    public_network_access_enabled                = false
    allowed_ips                                  = []
    network_rule_bypass_option                   = "None"
    local_authentication_enabled                 = true
    authentication_failure_mode                  = ""
    customer_managed_key_enforcement_enabled     = false
    identity                                     = null
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
    condition     = output.endpoint == "https://${var.name}.search.windows.net"
    error_message = "Azure AI Search endpoint output did not match the expected public endpoint format."
  }
}
