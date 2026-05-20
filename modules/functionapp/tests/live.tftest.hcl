mock_provider "azurerm" {}

mock_provider "azuread" {}

variables {
  resource_group_name        = "rg-ba-eus-prd-shared-management"
  location                   = "eastus"
  name                       = "func-iactest-dev-001"
  app_env                    = "dev"
  os_type                    = "Linux"
  service_plan_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-eus-prd-shared-management/providers/Microsoft.Web/serverFarms/asp-iactest-dev-001"
  storage_account_name       = "stiactestfunc001"
  storage_account_access_key = "ZmFrZS1zdG9yYWdlLWtleQ=="

  application_stack = {
    python_version = "3.11"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  app_admin_group = []
  app_user_group  = []

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_linux_secure_defaults" {
  command = plan

  assert {
    condition     = output.name == "func-iactest-dev-001"
    error_message = "Function App name was not propagated."
  }

  assert {
    condition     = output.public_network_access_enabled == false && output.storage_auth_mode == "AccessKey"
    error_message = "Secure defaults should disable public access and use access-key storage only when configured."
  }

  assert {
    condition     = output.tags.module == "functionapp" && output.tags.ManagedBy == "Terraform" && output.tags.Environment == "Development"
    error_message = "Effective tags did not include standardized Function App tags."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-ba-eus-prd-shared-management"
    location                    = "eastus"
    name                        = ""
    name_prefix                 = "func"
    workload_name               = "orders"
    app_env                     = "poc"
    include_environment_in_name = true
    location_code               = "eus"
    instance                    = "001"
    use_random_suffix           = false
    os_type                     = "Linux"
    service_plan_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-eus-prd-shared-management/providers/Microsoft.Web/serverFarms/asp-orders-poc-001"
    storage_account_name        = "storderspoc001"
    storage_account_access_key  = "ZmFrZS1zdG9yYWdlLWtleQ=="
    application_stack = {
      node_version = "20"
    }
    app_admin_group = []
    app_user_group  = []
  }

  assert {
    condition     = output.name == "func-orders-poc-eus-001"
    error_message = "Generated Function App name did not match the expected naming convention."
  }

  assert {
    condition     = output.location_code == "eus"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_managed_identity_storage_network_and_auth" {
  command = plan

  variables {
    resource_group_name           = "rg-ba-eus-prd-shared-management"
    location                      = "eastus"
    name                          = "func-iactest-prod-001"
    app_env                       = "prod"
    os_type                       = "Linux"
    service_plan_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-eus-prd-shared-management/providers/Microsoft.Web/serverFarms/asp-iactest-prod-001"
    storage_account_name          = "stiactestprod001"
    storage_uses_managed_identity = true

    system_assigned_identity_enabled = true
    identity_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-functionapp"
    ]

    application_stack = {
      docker = {
        image_name   = "functions/orders"
        image_tag    = "1.0.0"
        registry_url = "https://contoso.azurecr.io"
      }
    }

    app_settings = {
      FUNCTIONS_WORKER_RUNTIME = "custom"
      WEBSITE_RUN_FROM_PACKAGE = "1"
    }

    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = "00000000-0000-0000-0000-000000000000"
    virtual_network_subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-functions"
    vnet_route_all_enabled                        = true
    ip_restriction_default_action                 = "Deny"
    scm_use_main_ip_restriction                   = true
    ip_restrictions = [
      {
        name        = "allow-frontdoor"
        priority    = 100
        action      = "Allow"
        service_tag = "AzureFrontDoor.Backend"
        headers = [
          {
            x_azure_fdid = ["00000000-0000-0000-0000-000000000000"]
          }
        ]
      }
    ]

    app_admin_group = ["11111111-1111-1111-1111-111111111111"]
    app_user_group  = ["22222222-2222-2222-2222-222222222222"]
    role_assignments = {
      invoker = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        principal_type       = "Group"
        role_definition_name = "Reader"
      }
    }

    auth_settings_v2 = {
      default_provider       = "azureactivedirectory"
      require_authentication = true
      unauthenticated_action = "RedirectToLoginPage"
      active_directory_v2 = {
        client_id            = "44444444-4444-4444-4444-444444444444"
        tenant_auth_endpoint = "https://login.microsoftonline.com/55555555-5555-5555-5555-555555555555/v2.0"
      }
    }
  }

  assert {
    condition     = output.storage_auth_mode == "ManagedIdentity" && output.identity_type == "SystemAssigned, UserAssigned"
    error_message = "Managed identity storage should configure both storage auth mode and identity type."
  }

  assert {
    condition     = output.role_assignment_count == 3
    error_message = "Role assignment count should include admin, user, and custom assignments."
  }
}

run "plan_windows_private_endpoint_diagnostics_and_key_vault_storage" {
  command = plan

  variables {
    resource_group_name              = "rg-ba-eus-prd-shared-management"
    location                         = "eastus"
    name                             = "func-iactest-sec-001"
    app_env                          = "prod"
    os_type                          = "Windows"
    service_plan_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-eus-prd-shared-management/providers/Microsoft.Web/serverFarms/asp-iactest-sec-001"
    storage_key_vault_secret_id      = "https://kv-iactest-prod-001.vault.azure.net/secrets/function-storage/00000000000000000000000000000000"
    system_assigned_identity_enabled = true

    application_stack = {
      dotnet_version = "v8.0"
    }

    enable_private_endpoint                 = true
    private_endpoint_subnet_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_endpoint_network_interface_name = "nic-pep-func-iactest-sec-001"
    private_dns_zone_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
    ]

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-eus-prd-shared-management/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    diagnostic_log_categories      = ["AllLogs"]
    diagnostic_metric_categories   = ["AllMetrics"]
  }

  assert {
    condition     = output.storage_auth_mode == "KeyVaultSecret"
    error_message = "Key Vault storage secret mode should be reflected in outputs."
  }

  assert {
    condition     = output.private_endpoint_name == "pep-func-iactest-sec-001" && output.diagnostics_enabled == true
    error_message = "Private endpoint and diagnostics should be enabled for the secure Windows scenario."
  }
}
