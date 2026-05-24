provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name                = "rg-ba-cc-prd-shared-management"
  location                           = "canadacentral"
  name                               = "ais-iactest-prod-001"
  app_env                            = "prod"
  kind                               = "AIServices"
  sku_name                           = "S0"
  public_network_access_enabled      = false
  outbound_network_access_restricted = false
  local_auth_enabled                 = false
  dynamic_throttling_enabled         = false
  fqdns                              = []
  project_management_enabled         = false
  identity                           = null
  customer_managed_key               = null
  storage                            = []
  network_acls                       = null
  app_admin_group                    = []
  app_user_group                     = []
  diagnostic_log_categories          = []
  diagnostic_metric_categories       = ["AllMetrics"]
  diagnostic_log_category_groups     = []

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_named_ai_service" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Azure AI Services account test name was not propagated to the module."
  }

  assert {
    condition     = output.public_network_access_enabled == false && output.local_auth_enabled == false
    error_message = "Azure AI Services should disable public access and local auth by default in the hardened baseline."
  }

  assert {
    condition     = output.tags.Environment == "Production" && !contains(keys(output.tags), "ManagedBy") && !contains(keys(output.tags), "module") && !contains(keys(output.tags), "name") && !contains(keys(output.tags), "app_env")
    error_message = "Effective tags did not include standardized Azure AI Services tags."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-ba-cc-prd-shared-management"
    location                    = "canadacentral"
    name                        = ""
    name_prefix                 = "ais"
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
    condition     = output.name == "ais-shared-poc-cc-001"
    error_message = "Generated deterministic Azure AI Services name did not match the expected naming convention."
  }

  assert {
    condition     = output.location_code == "cc"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_identity_rbac_network_acls_and_diagnostics" {
  command = plan

  variables {
    resource_group_name             = "rg-ba-cc-prd-shared-management"
    location                        = "canadacentral"
    name                            = "ais-iactest-prod-rbac"
    app_env                         = "prod"
    system_managed_identity_enabled = true

    customer_managed_key = {
      key_vault_key_id = "https://kv-iactest-prod-001.vault.azure.net/keys/cmk/00000000000000000000000000000000"
    }

    network_acls = {
      default_action = "Deny"
      bypass         = "AzureServices"
      ip_rules       = ["203.0.113.10"]
    }

    app_admin_group = ["11111111-1111-1111-1111-111111111111"]
    app_user_group  = ["22222222-2222-2222-2222-222222222222"]

    role_assignments = {
      cognitive_services_user = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        principal_type       = "Group"
        role_definition_name = "Cognitive Services User"
      }
    }

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-cc-prd-shared-management/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    diagnostic_storage_account_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ba-cc-prd-shared-management/providers/Microsoft.Storage/storageAccounts/stiactestdiag001"
  }

  assert {
    condition     = output.identity_type == "SystemAssigned"
    error_message = "System-assigned identity should be enabled."
  }

  assert {
    condition     = output.custom_subdomain_name == "ais-iactest-prod-rbac"
    error_message = "Custom subdomain should auto-default to the account name when network ACLs are enabled."
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

run "plan_private_endpoint_network_injection_deployments_and_rai" {
  command = plan

  variables {
    resource_group_name             = "rg-ba-cc-prd-shared-management"
    location                        = "canadacentral"
    name                            = "ais-iactest-prod-ops"
    app_env                         = "prod"
    kind                            = "AIServices"
    sku_name                        = "S0"
    public_network_access_enabled   = false
    project_management_enabled      = true
    system_managed_identity_enabled = true

    enable_private_endpoint    = true
    private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_dns_zone_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com"
    ]

    network_injection = {
      scenario  = "agent"
      subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-ai-agents"
    }

    rai_policies = {
      strict = {
        name             = "rai-strict"
        base_policy_name = "Microsoft.Default"
        mode             = "Blocking"
        content_filters = [
          {
            name               = "Hate"
            filter_enabled     = true
            block_enabled      = true
            severity_threshold = "High"
            source             = "Prompt"
          }
        ]
      }
    }

    deployments = {
      chat = {
        name                   = "gpt-4o-mini"
        rai_policy_name        = "rai-strict"
        version_upgrade_option = "OnceNewDefaultVersionAvailable"
        model = {
          format  = "OpenAI"
          name    = "gpt-4o-mini"
          version = "2024-07-18"
        }
        sku = {
          name     = "GlobalStandard"
          capacity = 10
        }
      }
    }
  }

  assert {
    condition     = output.private_endpoint_name == "pep-ais-iactest-prod-ops"
    error_message = "Private endpoint name did not follow the standardized naming convention."
  }

  assert {
    condition     = output.custom_subdomain_name == "ais-iactest-prod-ops"
    error_message = "Custom subdomain should auto-default to the account name for private endpoint/project management scenarios."
  }

  assert {
    condition     = length(output.rai_policy_ids) == 1 && length(output.deployment_ids) == 1
    error_message = "Expected one RAI policy and one model deployment."
  }
}
