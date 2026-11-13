mock_provider "azurerm" {}

mock_provider "azuread" {}
mock_provider "random" {}

variables {
  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  name                = "oai-iactest-dev-001"
  app_env             = "dev"

  app_admin_group = []
  app_user_group  = []
  inherited_resource_group_tags = {
    CostCenter = "platform"
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
    error_message = "Azure OpenAI account test name was not propagated to the module."
  }

  assert {
    condition     = output.public_network_access_enabled == false && output.local_auth_enabled == false && output.identity_type == "SystemAssigned"
    error_message = "Secure defaults should disable public access, disable local auth, and enable system-assigned identity."
  }

  assert {
    condition     = output.merged_tags.CostCenter == "platform" && !contains(keys(output.merged_tags), "ManagedBy") && !contains(keys(output.merged_tags), "module")
    error_message = "Azure OpenAI tag inheritance or explicit-tag normalization failed."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-platform-dev"
    location                    = "canadacentral"
    name                        = ""
    name_prefix                 = "oai"
    workload_name               = "platform"
    app_env                     = "poc"
    include_environment_in_name = true
    location_code               = "cc"
    instance                    = "001"
    use_random_suffix           = false
    app_admin_group             = []
    app_user_group              = []
  }

  assert {
    condition     = output.name == "oai-platform-poc-cc-001"
    error_message = "Generated Azure OpenAI name did not match the expected naming convention."
  }

  assert {
    condition     = output.custom_subdomain_name == "oai-platform-poc-cc-001"
    error_message = "Custom subdomain should default to the generated account name."
  }
}

run "plan_private_endpoint_deployments_diagnostics_and_rbac" {
  command = plan

  variables {
    resource_group_name           = "rg-platform-prod"
    location                      = "canadacentral"
    name                          = "oai-iactest-prod-001"
    app_env                       = "prod"
    public_network_access_enabled = false

    enable_private_endpoint                 = true
    private_endpoint_subnet_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_endpoint_network_interface_name = "nic-pep-oai-iactest-prod-001"
    private_dns_zone_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
    ]

    network_acls = {
      default_action = "Deny"
      bypass         = "AzureServices"
    }

    deployments = {
      "gpt4o-mini" = {
        model_format           = "OpenAI"
        model_name             = "gpt-4o-mini"
        model_version          = "2024-07-18"
        sku_name               = "Standard"
        sku_capacity           = 10
        version_upgrade_option = "OnceNewDefaultVersionAvailable"
      }
      "embedding-large" = {
        model_format = "OpenAI"
        model_name   = "text-embedding-3-large"
        sku_name     = "Standard"
        sku_capacity = 10
      }
    }

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    diagnostic_log_categories      = ["AllLogs"]
    diagnostic_metric_categories   = ["AllMetrics"]

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
    condition     = length(output.deployment_names) == 2 && output.deployment_names["gpt4o-mini"] == "gpt4o-mini"
    error_message = "Expected two Azure OpenAI deployments."
  }

  assert {
    condition     = output.private_endpoint_name == "pep-oai-iactest-prod-001" && output.diagnostics_enabled == true
    error_message = "Private endpoint and diagnostics should be enabled in the private scenario."
  }

  assert {
    condition     = output.role_assignment_count == 3
    error_message = "Role assignment count should include admin, user, and custom assignments."
  }
}

run "plan_cmk_with_user_assigned_identity" {
  command = plan

  variables {
    resource_group_name = "rg-platform-prod"
    location            = "canadacentral"
    name                = "oai-iactest-cmk-001"
    app_env             = "prod"

    identity_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-openai"
    ]

    customer_managed_key = {
      key_vault_key_id   = "https://kv-iactest-prod-001.vault.azure.net/keys/cmk/00000000000000000000000000000000"
      identity_client_id = "44444444-4444-4444-4444-444444444444"
    }
  }

  assert {
    condition     = output.identity_type == "SystemAssigned, UserAssigned"
    error_message = "CMK scenario should configure system-assigned plus user-assigned identity."
  }
}

run "plan_question_answering_pair" {
  command = plan

  variables {
    resource_group_name                          = "rg-platform-prod"
    location                                     = "canadacentral"
    name                                         = "oai-iactest-qa-001"
    custom_question_answering_search_service_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-search/providers/Microsoft.Search/searchServices/srch-platform"
    custom_question_answering_search_service_key = "mock-search-key"
  }

  assert {
    condition     = azurerm_cognitive_account.this.custom_question_answering_search_service_id != null
    error_message = "Question answering search service integration should be configured when both paired inputs are supplied."
  }
}
