provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name                      = "rg-platform-dev"
  location                                 = "eastus"
  name                                     = "srch-iactest-prod-001"
  app_env                                  = "prod"
  sku                                      = "standard"
  replica_count                            = 1
  partition_count                          = 1
  hosting_mode                             = "default"
  semantic_search_sku                      = ""
  public_network_access_enabled            = false
  local_authentication_enabled             = false
  network_rule_bypass_option               = "None"
  app_admin_group                          = []
  app_user_group                           = []
  diagnostic_log_categories                = []
  diagnostic_metric_categories             = ["AllMetrics"]
  diagnostic_log_category_groups           = []
  customer_managed_key_enforcement_enabled = false

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_named_search_service" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Azure AI Search service test name was not propagated to the module."
  }

  assert {
    condition     = output.endpoint == "https://${var.name}.search.windows.net"
    error_message = "Azure AI Search endpoint output did not match the expected endpoint format."
  }

  assert {
    condition     = output.public_network_access_enabled == false && output.local_authentication_enabled == false
    error_message = "Azure AI Search should disable public access and local authentication by default in the hardened baseline."
  }

  assert {
    condition     = output.tags.module == "azure_ai_search" && output.tags.ManagedBy == "Terraform" && output.tags.Environment == "Production"
    error_message = "Effective tags did not include standardized Azure AI Search tags."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-platform-dev"
    location                    = "eastus"
    name                        = ""
    name_prefix                 = "srch"
    workload_name               = "shared"
    app_env                     = "poc"
    include_environment_in_name = true
    location_code               = "eus"
    instance                    = "001"
    use_random_suffix           = false
    app_admin_group             = []
    app_user_group              = []
  }

  assert {
    condition     = output.name == "srch-shared-poc-eus-001"
    error_message = "Generated deterministic Azure AI Search name did not match the expected naming convention."
  }

  assert {
    condition     = output.location_code == "eus"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_identity_rbac_and_diagnostics" {
  command = plan

  variables {
    resource_group_name                      = "rg-platform-dev"
    location                                 = "eastus"
    name                                     = "srch-iactest-prod-rbac"
    app_env                                  = "prod"
    system_managed_identity_enabled          = true
    customer_managed_key_enforcement_enabled = true

    app_admin_group = ["11111111-1111-1111-1111-111111111111"]
    app_user_group  = ["22222222-2222-2222-2222-222222222222"]

    role_assignments = {
      search_index_data_reader = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        principal_type       = "Group"
        role_definition_name = "Search Index Data Reader"
      }
    }

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-dev/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    diagnostic_storage_account_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-dev/providers/Microsoft.Storage/storageAccounts/stiactestdiag001"
  }

  assert {
    condition     = output.identity_type == "SystemAssigned"
    error_message = "System-assigned identity should be enabled."
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

run "plan_private_endpoint_shared_links_and_scale" {
  command = plan

  variables {
    resource_group_name           = "rg-platform-dev"
    location                      = "eastus"
    name                          = "srch-iactest-prod-ops"
    app_env                       = "prod"
    sku                           = "standard3"
    hosting_mode                  = "highDensity"
    replica_count                 = 3
    partition_count               = 3
    semantic_search_sku           = "standard"
    public_network_access_enabled = false

    enable_private_endpoint    = true
    private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_dns_zone_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net"
    ]

    shared_private_link_services = {
      blob_ingest = {
        name               = "spl-blob-ingest"
        subresource_name   = "blob"
        target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data/providers/Microsoft.Storage/storageAccounts/stingest001"
        request_message    = "Allow Azure AI Search indexers to read private blob content."
      }
    }
  }

  assert {
    condition     = output.private_endpoint_name == "pep-srch-iactest-prod-ops"
    error_message = "Private endpoint name did not follow the standardized naming convention."
  }

  assert {
    condition     = output.hosting_mode == "highDensity" && output.sku == "standard3" && output.partition_count == 3
    error_message = "High-density standard3 scale settings were not propagated."
  }

  assert {
    condition     = length(output.shared_private_link_service_ids) == 1
    error_message = "Expected one shared private link resource."
  }
}
