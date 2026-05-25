provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name             = "rg-ba-cc-prd-shared-management"
  location                        = "canadacentral"
  name                            = "stiactestprod001"
  app_env                         = "prod"
  default_to_oauth_authentication = true
  app_admin_group                 = []
  app_user_group                  = []

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_named_storage_account" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Storage account name output did not match input."
  }

  assert {
    condition     = output.location == var.location
    error_message = "Storage account location output did not match input."
  }

  assert {
    condition     = output.default_to_oauth_authentication == true
    error_message = "Storage account did not enable default_to_oauth_authentication as expected."
  }

  assert {
    condition     = output.tags.Environment == "Production" && !contains(keys(output.tags), "ManagedBy") && !contains(keys(output.tags), "module") && !contains(keys(output.tags), "name") && !contains(keys(output.tags), "app_env")
    error_message = "Effective tags did not include standardized storage account tags."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-ba-cc-prd-shared-management"
    location                    = "canadacentral"
    name                        = ""
    name_prefix                 = "st"
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
    condition     = output.name == "stsharedpoccc001"
    error_message = "Generated deterministic storage account name did not match the expected convention."
  }

  assert {
    condition     = output.location_code == "cc"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_hardened_data_services" {
  command = plan

  variables {
    resource_group_name              = "rg-ba-cc-prd-shared-management"
    location                         = "canadacentral"
    name                             = "stiactestprod002"
    app_env                          = "prod"
    account_tier                     = "Standard"
    account_replication_type         = "ZRS"
    account_kind                     = "StorageV2"
    min_tls_version                  = "TLS1_2"
    public_network_access_enabled    = false
    shared_access_key_enabled        = false
    default_to_oauth_authentication  = true
    allow_nested_items_to_be_public  = false
    cross_tenant_replication_enabled = false

    blob_properties = {
      versioning_enabled                     = true
      change_feed_enabled                    = true
      change_feed_retention_in_days          = 30
      last_access_time_enabled               = true
      delete_retention_policy_days           = 30
      container_delete_retention_policy_days = 30
      restore_policy_days                    = 7
      cors_rules = [
        {
          allowed_headers    = ["*"]
          allowed_methods    = ["GET"]
          allowed_origins    = ["https://example.com"]
          exposed_headers    = ["x-ms-request-id"]
          max_age_in_seconds = 3600
        }
      ]
    }

    static_website = {
      index_document     = "index.html"
      error_404_document = "404.html"
    }

    routing = {
      choice                      = "MicrosoftRouting"
      publish_microsoft_endpoints = true
    }

    immutability_policy = {
      period_since_creation_in_days = 30
      state                         = "Unlocked"
    }

    containers = {
      ingest = {
        metadata = {
          purpose = "landing"
        }
      }
    }

    queues = {
      jobs = {}
    }

    tables = {
      AuditEvents = {}
    }

    role_assignments = {
      storage_blob_data_reader = {
        principal_id         = "11111111-1111-1111-1111-111111111111"
        principal_type       = "Group"
        role_definition_name = "Storage Blob Data Reader"
      }
    }

    app_admin_group = ["22222222-2222-2222-2222-222222222222"]
    app_user_group  = ["33333333-3333-3333-3333-333333333333"]
  }

  assert {
    condition     = output.network_rules_config.enabled == true && output.network_rules_config.default_action == "Deny"
    error_message = "Network rules should be enabled with Deny default action by default."
  }

  assert {
    condition     = output.role_assignment_count == 12
    error_message = "Role assignment count should include admin management and data-plane roles, user, custom, and current Terraform execution identity role assignments."
  }
}

run "plan_identity_private_endpoint_diagnostics" {
  command = plan

  variables {
    resource_group_name             = "rg-ba-cc-prd-shared-management"
    location                        = "canadacentral"
    name                            = "stiactestprod003"
    app_env                         = "prod"
    system_managed_identity_enabled = true

    managed_identity_role_assignments = {
      blob_contributor = {
        scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-cc-prd-shared-management"
        role_definition_name = "Storage Blob Data Contributor"
      }
    }

    private_endpoint_subresource_names = ["blob", "dfs"]
    private_endpoint_subnet_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-cc-prd-shared-management/providers/Microsoft.Network/virtualNetworks/vnet-iactest-prod-001/subnets/snet-private-endpoints"
    private_dns_zone_ids = {
      blob = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-cc-prd-shared-management/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
      dfs  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-cc-prd-shared-management/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"
    }

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-cc-prd-shared-management/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    diagnostic_storage_account_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-cc-prd-shared-management/providers/Microsoft.Storage/storageAccounts/stiactestdiag001"
  }

  assert {
    condition     = output.identity_type == "SystemAssigned"
    error_message = "System assigned identity should be enabled."
  }

  assert {
    condition     = output.diagnostics_enabled == true
    error_message = "Diagnostics should be enabled when destinations are configured."
  }

  assert {
    condition     = length(output.private_endpoint_names) == 2
    error_message = "Expected one private endpoint per requested subresource."
  }
}
