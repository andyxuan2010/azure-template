mock_provider "azurerm" {}

mock_provider "azapi" {}

mock_provider "azuread" {}

variables {
  resource_group_name = "rg-platform-dev"
  location            = "eastus"
  server_name         = "sql-iactest-dev-001"
  database_name       = "sqldb-iactest-dev-001"
  app_env             = "dev"
  admin_username      = "sqladminuser"
  admin_password      = "TerraformLiveTest-ChangeMe123!"
  ad_admin_login_name = "sql-admin-group"
  ad_admin_object_id  = "11111111-1111-1111-1111-111111111111"

  private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-private-endpoints"

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_secure_defaults" {
  command = plan

  assert {
    condition     = output.server_name == var.server_name && output.database_name == var.database_name
    error_message = "SQL server or database name outputs did not match the explicit inputs."
  }

  assert {
    condition     = output.public_network_access_enabled == false && output.server_identity_type == "SystemAssigned" && output.azuread_administrator_enabled == true
    error_message = "Secure defaults should disable public access, enable system-assigned identity, and configure an Entra administrator."
  }

  assert {
    condition     = output.tags.Environment == "Development" && !contains(keys(output.tags), "ManagedBy") && !contains(keys(output.tags), "module") && !contains(keys(output.tags), "name") && !contains(keys(output.tags), "app_env")
    error_message = "Merged tags did not include standardized SQL DB tags."
  }
}

run "plan_generated_names_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-platform-poc"
    location                    = "eastus"
    server_name                 = ""
    database_name               = ""
    workload_name               = "platform"
    app_env                     = "poc"
    include_environment_in_name = true
    location_code               = "eus"
    instance                    = "001"
    use_random_suffix           = false
    admin_username              = "sqladminuser"
    admin_password              = "TerraformLiveTest-ChangeMe123!"
    ad_admin_login_name         = "sql-admin-group"
    ad_admin_object_id          = "11111111-1111-1111-1111-111111111111"
    private_endpoint_subnet_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-private-endpoints"
  }

  assert {
    condition     = output.server_name == "sql-platform-poc-eus-001" && output.database_name == "sqldb-platform-poc-eus-001"
    error_message = "Generated SQL names did not match the expected naming convention."
  }

  assert {
    condition     = output.location_code == "eus"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_private_endpoint_diagnostics_security_and_rbac" {
  command = plan

  variables {
    resource_group_name = "rg-platform-prod"
    location            = "eastus"
    server_name         = "sql-iactest-prod-001"
    database_name       = "sqldb-iactest-prod-001"
    app_env             = "prod"
    sku_name            = "GP_Gen5_2"
    max_size_gb         = 64
    admin_username      = "sqladminuser"
    admin_password      = "TerraformLiveTest-ChangeMe123!"
    ad_admin_login_name = "sql-admin-group"
    ad_admin_object_id  = "11111111-1111-1111-1111-111111111111"

    public_network_access_enabled = false
    enable_private_endpoint       = true
    private_endpoint_subnet_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-private-endpoints"
    private_dns_zone_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
    ]

    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/log-platform-prod-001"
    diagnostic_log_categories  = ["AllLogs"]

    enable_long_term_retention = true
    long_term_retention_policy = {
      weekly_retention          = 12
      monthly_retention         = 12
      yearly_retention          = 3
      week_of_year              = 1
      immutable_backups_enabled = true
    }

    enable_threat_detection          = true
    enable_database_threat_detection = true
    threat_detection_email_addresses = ["security@example.com"]

    app_admin_group = ["22222222-2222-2222-2222-222222222222"]
    app_user_group  = ["33333333-3333-3333-3333-333333333333"]
    role_assignments = {
      database_reader = {
        principal_id         = "44444444-4444-4444-4444-444444444444"
        principal_type       = "Group"
        role_definition_name = "Reader"
        scope                = "database"
      }
    }
  }

  assert {
    condition     = output.private_endpoint_name == "pep-sql-iactest-prod-001" && output.diagnostics_enabled == true
    error_message = "Private endpoint and diagnostics should be enabled in the hardened SQL scenario."
  }

  assert {
    condition     = output.backup_configuration.long_term_retention_enabled == true && output.security_configuration.threat_detection_enabled == true
    error_message = "LTR and threat detection should be reflected in configuration outputs."
  }

  assert {
    condition     = output.role_assignment_count == 3
    error_message = "Role assignment count should include admin, user, and custom role assignments."
  }
}

run "plan_cmk_entra_only_and_failover_group" {
  command = plan

  variables {
    resource_group_name         = "rg-platform-prod"
    location                    = "eastus"
    server_name                 = "sql-iactest-sec-001"
    database_name               = "sqldb-iactest-sec-001"
    app_env                     = "prod"
    azuread_authentication_only = true
    ad_admin_login_name         = "sql-admin-group"
    ad_admin_object_id          = "11111111-1111-1111-1111-111111111111"
    private_endpoint_subnet_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-private-endpoints"
    enable_diagnostics          = true
    log_analytics_workspace_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/log-platform-prod-001"
    enable_long_term_retention  = true
    long_term_retention_policy = {
      weekly_retention = 4
    }

    identity_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-sql"
    ]
    primary_user_assigned_identity_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-sql"
    transparent_data_encryption_key_vault_key_id = "https://kv-platform-prod-001.vault.azure.net/keys/sql-tde/00000000000000000000000000000000"

    database_identity_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-sql-db"
    ]
    database_transparent_data_encryption_key_vault_key_id               = "https://kv-platform-prod-001.vault.azure.net/keys/sqldb-tde/00000000000000000000000000000000"
    database_transparent_data_encryption_key_automatic_rotation_enabled = true

    failover_group = {
      partner_server_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-dr/providers/Microsoft.Sql/servers/sql-iactest-sec-dr-001"
      read_write_endpoint_failover_policy = {
        mode          = "Automatic"
        grace_minutes = 60
      }
    }
  }

  assert {
    condition     = output.azuread_authentication_only == true && output.server_identity_type == "SystemAssigned, UserAssigned"
    error_message = "Entra-only CMK scenario should enable Entra-only auth and combined server identity."
  }

  assert {
    condition     = output.failover_group_name == "fog-sql-iactest-sec-001"
    error_message = "Failover group should use the default standardized name."
  }
}

run "plan_import_and_public_firewall_demo" {
  command = plan

  variables {
    resource_group_name           = "rg-platform-dev"
    location                      = "eastus"
    server_name                   = "sql-iactest-import-001"
    database_name                 = "sqldb-iactest-import-001"
    app_env                       = "dev"
    sku_name                      = "S0"
    admin_username                = "sqladminuser"
    admin_password                = "TerraformLiveTest-ChangeMe123!"
    ad_admin_login_name           = "sql-admin-group"
    ad_admin_object_id            = "11111111-1111-1111-1111-111111111111"
    enable_private_endpoint       = false
    public_network_access_enabled = true
    allow_azure_services          = true
    enable_audit                  = false
    create_mode                   = "Default"

    firewall_rules = {
      office = {
        start_ip_address = "203.0.113.10"
        end_ip_address   = "203.0.113.10"
      }
    }

    database_import = {
      administrator_login          = "sqladminuser"
      administrator_login_password = "TerraformLiveTest-ChangeMe123!"
      authentication_type          = "Sql"
      storage_key                  = "fake-storage-key"
      storage_key_type             = "StorageAccessKey"
      storage_uri                  = "https://stexample.blob.core.windows.net/backups/database.bacpac"
    }
  }

  assert {
    condition     = output.public_network_access_enabled == true && output.security_configuration.private_endpoint_enabled == false
    error_message = "Public demo scenario should enable public access and disable the private endpoint."
  }
}

run "plan_serverless_free_offer" {
  command = plan

  variables {
    resource_group_name = "rg-platform-dev"
    location            = "canadacentral"
    server_name         = "sql-iactest-free-001"
    database_name       = "sqldb-iactest-free-001"
    app_env             = "dev"
    sku_name            = "GP_S_Gen5_2"
    max_size_gb         = 32

    backup_storage_redundancy   = "Local"
    geo_backup_enabled          = false
    auto_pause_delay_in_minutes = 60
    min_capacity                = 0.5

    use_free_limit                 = true
    free_limit_exhaustion_behavior = "AutoPause"

    public_network_access_enabled = true
    enable_private_endpoint       = false
    enable_audit                  = false

    admin_username      = "sqladminuser"
    admin_password      = "TerraformLiveTest-ChangeMe123!"
    ad_admin_login_name = "sql-admin-group"
    ad_admin_object_id  = "11111111-1111-1111-1111-111111111111"
  }

  assert {
    condition     = output.free_limit_configuration.enabled == true && output.free_limit_configuration.exhaustion_behavior == "AutoPause"
    error_message = "Serverless free offer scenario should enable free monthly limits with AutoPause behavior."
  }
}
