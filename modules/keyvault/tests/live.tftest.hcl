mock_provider "azurerm" {
  mock_data "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-private-endpoints"
    }
  }

  mock_data "azurerm_private_dns_zone" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
    }
  }

  mock_data "azurerm_client_config" {
    defaults = {
      object_id       = "00000000-0000-0000-0000-000000000001"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000002"
    }
  }

  mock_data "azurerm_resource_group" {
    defaults = {
      location = "canadacentral"
      name     = "rg-ccoe-iac-cc-dev"
      tags = {
        application_id = "platform"
      }
    }
  }
}

mock_provider "azuread" {}
mock_provider "random" {}

variables {
  resource_group_name                                       = "rg-ccoe-iac-cc-dev"
  location                                                  = "canadacentral"
  tenant_id                                                 = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
  name                                                      = "kviactestprod001"
  app_env                                                   = "prod"
  sku_name                                                  = "standard"
  enable_rbac_authorization                                 = true
  grant_current_caller_secrets_officer                      = true
  grant_current_terraform_service_principal_key_vault_roles = true
  public_network_access_enabled                             = false
  purge_protection_enabled                                  = false
  soft_delete_retention_days                                = 90
  enabled_for_deployment                                    = false
  enabled_for_disk_encryption                               = false
  enabled_for_template_deployment                           = false
  contacts = [
    {
      email = "admin@example.com"
      name  = "Admin"
    }
  ]
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
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }
}

run "plan" {
  command = plan

  providers = {
    azurerm = azurerm
    azuread = azuread
  }

  assert {
    condition     = output.name == var.name
    error_message = "Key Vault test name was not propagated to the module."
  }

  assert {
    condition     = contains(keys(output.current_terraform_service_principal_role_assignment_ids), "administrator")
    error_message = "Key Vault did not grant Key Vault Administrator to the Terraform execution identity as expected."
  }

  assert {
    condition     = length(output.current_terraform_service_principal_role_assignment_ids) == 2
    error_message = "Key Vault did not grant Contributor and Key Vault Administrator to the Terraform execution identity as expected."
  }

  assert {
    condition     = output.tags.CostCenter == "platform"
    error_message = "Inherited resource-group tags were not applied."
  }
}

run "plan_private_endpoint_lookup" {
  command = plan

  providers = {
    azurerm = azurerm
    azuread = azuread
  }

  variables {
    enable_private_endpoint                      = true
    private_endpoint_subnet_name                 = "snet-private-endpoints"
    private_endpoint_vnet_name                   = "vnet-prod"
    private_endpoint_network_resource_group_name = "rg-network"
    private_dns_zone_name                        = "privatelink.vaultcore.azure.net"
    private_dns_zone_resource_group_name         = "rg-dns"
  }

  assert {
    condition     = length(data.azurerm_subnet.pep) == 1 && length(data.azurerm_private_dns_zone.this) == 1
    error_message = "Private endpoint subnet and DNS zone lookups should each run once."
  }
}
