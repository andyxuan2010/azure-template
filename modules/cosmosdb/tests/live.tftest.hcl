mock_provider "azurerm" {}

mock_provider "azuread" {}

variables {
  resource_group_name = "rg-platform-dev"
  location            = "eastus"
  name                = "cosmos-iactest-dev-001"
  app_env             = "dev"

  app_admin_group = []
  app_user_group  = []

  sql_databases = {
    app = {
      autoscale_max_ru = 4000
    }
  }

  sql_containers = {
    orders = {
      database_name       = "app"
      partition_key_paths = ["/tenantId"]
      autoscale_max_ru    = 4000
    }
  }

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_secure_defaults" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Cosmos DB account test name was not propagated to the module."
  }

  assert {
    condition     = output.public_network_access_enabled == false && output.local_authentication_disabled == true && output.identity_type == "SystemAssigned"
    error_message = "Secure defaults should disable public access, disable local auth, and enable system-assigned identity."
  }

  assert {
    condition     = output.merged_tags.Environment == "Development" && !contains(keys(output.merged_tags), "ManagedBy") && !contains(keys(output.merged_tags), "module") && !contains(keys(output.merged_tags), "name") && !contains(keys(output.merged_tags), "app_env")
    error_message = "Cosmos DB merged tags did not include standardized tags."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-platform-dev"
    location                    = "eastus"
    name                        = ""
    name_prefix                 = "cosmos"
    workload_name               = "orders"
    app_env                     = "poc"
    include_environment_in_name = true
    location_code               = "eus"
    instance                    = "001"
    use_random_suffix           = false
    app_admin_group             = []
    app_user_group              = []
  }

  assert {
    condition     = output.name == "cosmos-orders-poc-eus-001"
    error_message = "Generated Cosmos DB name did not match the expected naming convention."
  }
}

run "plan_private_endpoint_diagnostics_and_rbac" {
  command = plan

  variables {
    resource_group_name           = "rg-platform-prod"
    location                      = "eastus"
    name                          = "cosmos-iactest-prod-001"
    app_env                       = "prod"
    public_network_access_enabled = false

    enable_private_endpoint                 = true
    private_endpoint_subnet_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_endpoint_network_interface_name = "nic-pep-cosmos-iactest-prod-001"
    private_dns_zone_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com"
    ]

    sql_databases = {
      app = {
        throughput = 400
      }
    }

    sql_containers = {
      orders = {
        database_name       = "app"
        partition_key_paths = ["/tenantId"]
        throughput          = 400
        indexing_policy = {
          included_paths = [{ path = "/*" }]
          excluded_paths = [{ path = "/largePayload/?" }]
        }
      }
    }

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    diagnostic_log_categories      = ["AllLogs"]
    diagnostic_metric_categories   = ["Requests"]

    app_admin_group = ["11111111-1111-1111-1111-111111111111"]
    app_user_group  = ["22222222-2222-2222-2222-222222222222"]
    role_assignments = {
      reader = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        principal_type       = "Group"
        role_definition_name = "Reader"
      }
    }
  }

  assert {
    condition     = length(output.sql_database_ids) == 1 && length(output.sql_container_ids) == 1
    error_message = "Expected one SQL database and one SQL container."
  }

  assert {
    condition     = output.private_endpoint_name == "pep-cosmos-iactest-prod-001" && output.diagnostics_enabled == true
    error_message = "Private endpoint and diagnostics should be enabled in the private scenario."
  }

  assert {
    condition     = output.role_assignment_count == 3
    error_message = "Role assignment count should include admin, user, and custom assignments."
  }
}
