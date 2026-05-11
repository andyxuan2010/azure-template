provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name     = "rg-ba-eus-prd-shared-management"
  location                = "eastus"
  name                    = "vnet-ba-cc-prd-shared-management-01"
  address_space           = ["10.250.0.0/16"]
  dns_servers             = []
  bgp_community           = null
  edge_zone               = null
  flow_timeout_in_minutes = null
  ddos_protection_plan_id = ""
  subnets = {
    app = {
      address_prefixes                              = ["10.250.1.0/24"]
      service_endpoints                             = ["Microsoft.Storage", "Microsoft.KeyVault"]
      service_endpoint_policy_ids                   = []
      private_endpoint_network_policies             = "Enabled"
      private_link_service_network_policies_enabled = true
      delegations                                   = {}
    }
    private_endpoint = {
      address_prefixes                              = ["10.250.10.0/24"]
      service_endpoints                             = []
      service_endpoint_policy_ids                   = []
      private_endpoint_network_policies             = "Disabled"
      private_link_service_network_policies_enabled = true
      delegations                                   = {}
    }
  }
  app_admin_group              = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group               = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  enable_diagnostics           = false
  diagnostic_log_categories    = []
  diagnostic_metric_categories = ["AllMetrics"]
  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "apply" {
  command = apply
}
