provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name                   = "rg-ccoe-iac-cc-dev"
  location                              = "canadacentral"
  name                                  = "dbw-iactest-prod-001"
  app_env                               = "prod"
  sku                                   = "premium"
  public_network_access_enabled         = false
  network_security_group_rules_required = "NoAzureDatabricksRules"
  customer_managed_key_enabled          = false
  infrastructure_encryption_enabled     = false
  default_storage_firewall_enabled      = false
  app_admin_group                       = []
  app_user_group                        = []
  diagnostic_log_categories             = []
  diagnostic_metric_categories          = ["AllMetrics"]
  diagnostic_log_category_groups        = []

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_named_databricks_workspace" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Databricks workspace test name was not propagated to the module."
  }

  assert {
    condition     = output.public_network_access_enabled == false
    error_message = "Databricks public network access should be disabled by default."
  }

  assert {
    condition     = output.tags.Environment == "Production" && !contains(keys(output.tags), "ManagedBy") && !contains(keys(output.tags), "module") && !contains(keys(output.tags), "name") && !contains(keys(output.tags), "app_env")
    error_message = "Effective tags did not include standardized Databricks tags."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-ccoe-iac-cc-dev"
    location                    = "canadacentral"
    name                        = ""
    name_prefix                 = "dbw"
    workload_name               = "shared"
    app_env                     = "poc"
    include_environment_in_name = true
    location_code               = "cc"
    instance                    = "001"
    use_random_suffix           = false
    app_admin_group             = []
    app_user_group              = []
  }

  assert {
    condition     = output.name == "dbw-shared-poc-cc-001"
    error_message = "Generated deterministic Databricks name did not match the expected naming convention."
  }

  assert {
    condition     = output.location_code == "cc"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_vnet_injection_rbac_and_diagnostics" {
  command = plan

  variables {
    resource_group_name                   = "rg-ccoe-iac-cc-dev"
    location                              = "canadacentral"
    name                                  = "dbw-iactest-prod-secure"
    app_env                               = "prod"
    sku                                   = "premium"
    public_network_access_enabled         = false
    network_security_group_rules_required = "NoAzureDatabricksRules"

    custom_parameters = {
      virtual_network_id                                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example"
      public_subnet_name                                   = "snet-databricks-public"
      private_subnet_name                                  = "snet-databricks-private"
      public_subnet_network_security_group_association_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/networkSecurityGroups/nsg-dbx-public/subnets/snet-databricks-public"
      private_subnet_network_security_group_association_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/networkSecurityGroups/nsg-dbx-private/subnets/snet-databricks-private"
      no_public_ip                                         = true
      storage_account_sku_name                             = "Standard_ZRS"
    }

    enhanced_security_compliance = {
      automatic_cluster_update_enabled      = true
      enhanced_security_monitoring_enabled  = true
      compliance_security_profile_enabled   = true
      compliance_security_profile_standards = ["HIPAA"]
    }

    app_admin_group = ["11111111-1111-1111-1111-111111111111"]
    app_user_group  = ["22222222-2222-2222-2222-222222222222"]

    role_assignments = {
      workspace_reader = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        principal_type       = "Group"
        role_definition_name = "Reader"
      }
    }

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    diagnostic_storage_account_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Storage/storageAccounts/stiactestdiag001"
  }

  assert {
    condition     = output.diagnostics_enabled == true
    error_message = "Diagnostics should be enabled when destinations are configured."
  }

  assert {
    condition     = output.role_assignment_count == 3
    error_message = "Role assignment count should include admin, user, and custom assignments."
  }
}

run "plan_access_connector_cmk_and_private_endpoints" {
  command = plan

  variables {
    resource_group_name               = "rg-ccoe-iac-cc-dev"
    location                          = "canadacentral"
    name                              = "dbw-iactest-prod-uc"
    app_env                           = "prod"
    sku                               = "premium"
    public_network_access_enabled     = false
    customer_managed_key_enabled      = true
    infrastructure_encryption_enabled = true

    create_access_connector          = true
    default_storage_firewall_enabled = true
    access_connector_role_assignments = {
      external_storage = {
        scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data/providers/Microsoft.Storage/storageAccounts/stlake001"
        role_definition_name = "Storage Blob Data Contributor"
      }
    }

    managed_disk_cmk_key_vault_id                       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-security/providers/Microsoft.KeyVault/vaults/kv-iactest-prod-001"
    managed_disk_cmk_key_vault_key_id                   = "https://kv-iactest-prod-001.vault.azure.net/keys/databricks-disk/00000000000000000000000000000000"
    managed_disk_cmk_rotation_to_latest_version_enabled = true
    managed_services_cmk_key_vault_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-security/providers/Microsoft.KeyVault/vaults/kv-iactest-prod-001"
    managed_services_cmk_key_vault_key_id               = "https://kv-iactest-prod-001.vault.azure.net/keys/databricks-services/00000000000000000000000000000000"

    root_dbfs_customer_managed_key = {
      key_vault_key_id = "https://kv-iactest-prod-001.vault.azure.net/keys/databricks-root-dbfs/00000000000000000000000000000000"
      key_vault_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-security/providers/Microsoft.KeyVault/vaults/kv-iactest-prod-001"
    }

    private_endpoint_subresource_names = ["databricks_ui_api"]
    private_endpoint_subnet_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_dns_zone_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azuredatabricks.net"
    ]
  }

  assert {
    condition     = output.access_connector_name == "dac-dbw-iactest-prod-uc"
    error_message = "Access connector name did not follow the standardized naming convention."
  }

  assert {
    condition     = length(output.private_endpoint_names) == 1
    error_message = "Expected one Databricks private endpoint."
  }

  assert {
    condition     = output.role_assignment_count == 1
    error_message = "Expected one access connector role assignment in this scenario."
  }
}
