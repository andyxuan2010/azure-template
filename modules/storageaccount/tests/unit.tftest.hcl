mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      object_id       = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
    }
  }
}

mock_provider "azurerm" {
  alias = "prod"
}

mock_provider "azuread" {}
mock_provider "random" {}

variables {
  resource_group_name = "rg-storage-prod"
  location            = "canadacentral"
  inherited_resource_group_tags = {
    Owner = "Platform"
  }
  name                                                    = "stplatformprod001"
  app_env                                                 = "prod"
  app_admin_group                                         = []
  app_user_group                                          = []
  grant_current_terraform_service_principal_storage_roles = false
}

run "plan_secure_defaults" {
  command = plan

  assert {
    condition     = azurerm_storage_account.this.name == "stplatformprod001"
    error_message = "The explicit storage account name was not used."
  }

  assert {
    condition = (
      azurerm_storage_account.this.public_network_access_enabled == false &&
      azurerm_storage_account.this.allow_nested_items_to_be_public == false &&
      azurerm_storage_account.this.default_to_oauth_authentication == true &&
      azurerm_storage_account.this.min_tls_version == "TLS1_2"
    )
    error_message = "Storage account secure defaults regressed."
  }

  assert {
    condition     = output.network_rules_config.enabled && output.network_rules_config.default_action == "Deny"
    error_message = "Network rules must default to enabled with a Deny action."
  }

  assert {
    condition     = output.tags.Owner == "Platform"
    error_message = "Plan-known inherited resource-group tags were not applied."
  }
}

run "plan_private_endpoints_and_diagnostics" {
  command = plan

  variables {
    system_managed_identity_enabled    = true
    private_endpoint_subresource_names = ["blob", "dfs"]
    private_endpoint_subnet_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-private-endpoints"
    private_dns_zone_ids = {
      blob = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
      dfs  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"
    }
    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-platform"
  }

  assert {
    condition     = length(azurerm_private_endpoint.this) == 2
    error_message = "Expected one private endpoint per requested storage subresource."
  }

  assert {
    condition     = output.identity_type == "SystemAssigned" && output.diagnostics_enabled
    error_message = "Managed identity and diagnostics were not enabled."
  }
}
