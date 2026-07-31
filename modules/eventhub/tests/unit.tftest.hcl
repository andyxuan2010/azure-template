mock_provider "azurerm" {}
mock_provider "azuread" {}
mock_provider "random" {}

variables {
  resource_group_name           = "rg-ccoe-iac-cc-dev"
  location                      = "canadacentral"
  name                          = "evhns-iactest-prod-001"
  app_env                       = "prod"
  sku                           = "Standard"
  capacity                      = 1
  local_authentication_enabled  = false
  public_network_access_enabled = false

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

run "plan_named_namespace_secure_baseline" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Event Hubs namespace test name was not propagated to the module."
  }

  assert {
    condition     = output.public_network_access_enabled == false && output.local_authentication_enabled == false
    error_message = "Event Hubs secure baseline should disable public network access and local authentication."
  }

  assert {
    condition     = output.merged_tags.CostCenter == "platform" && !contains(keys(output.merged_tags), "ManagedBy") && !contains(keys(output.merged_tags), "module")
    error_message = "Event Hubs tag inheritance or explicit-tag normalization failed."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-ccoe-iac-cc-dev"
    location                    = "canadacentral"
    name                        = ""
    name_prefix                 = "evhns"
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
    condition     = output.name == "evhns-shared-poc-cc-001"
    error_message = "Generated deterministic Event Hubs namespace name did not match the expected naming convention."
  }

  assert {
    condition     = output.location_code == "cc"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_streaming_features_rbac_and_diagnostics" {
  command = plan

  variables {
    resource_group_name          = "rg-ccoe-iac-cc-dev"
    location                     = "canadacentral"
    name                         = "evhns-iactest-prod-feat"
    app_env                      = "prod"
    local_authentication_enabled = true
    auto_inflate_enabled         = true
    maximum_throughput_units     = 4

    eventhubs = {
      telemetry = {
        name              = "telemetry"
        partition_count   = 4
        message_retention = 3
        status            = "Active"
        retention_description = {
          cleanup_policy          = "Delete"
          retention_time_in_hours = 72
        }
        capture_description = {
          enabled             = true
          encoding            = "Avro"
          interval_in_seconds = 300
          size_limit_in_bytes = 10485760
          destination = {
            archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
            blob_container_name = "eventhub-capture"
            storage_account_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-storage/providers/Microsoft.Storage/storageAccounts/stiactestcapture"
          }
        }
        consumer_groups = {
          processors = {
            user_metadata = "stream-processing"
          }
        }
        authorization_rules = {
          telemetry_sender = {
            send = true
          }
        }
      }
    }

    authorization_rules = {
      namespace_sender = {
        send = true
      }
    }

    schema_groups = {
      telemetry = {
        schema_compatibility = "Forward"
        schema_type          = "Avro"
      }
    }

    app_admin_group = ["11111111-1111-1111-1111-111111111111"]
    app_user_group  = ["22222222-2222-2222-2222-222222222222"]

    role_assignments = {
      data_receiver = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        principal_type       = "Group"
        role_definition_name = "Azure Event Hubs Data Receiver"
      }
    }

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    diagnostic_log_categories      = ["OperationalLogs", "RuntimeAuditLogs"]
    diagnostic_metric_categories   = ["AllMetrics"]
  }

  assert {
    condition     = length(output.eventhub_names) == 1 && output.eventhub_names.telemetry == "telemetry"
    error_message = "Expected one telemetry Event Hub to be planned."
  }

  assert {
    condition     = output.diagnostics_enabled == true
    error_message = "Diagnostics should be enabled when a destination is configured."
  }

  assert {
    condition     = output.role_assignment_count == 3
    error_message = "Role assignment count should include admin, user, and custom assignments."
  }
}

run "plan_private_endpoint_network_rules_cmk_and_dr" {
  command = plan

  variables {
    resource_group_name           = "rg-ccoe-iac-cc-dev"
    location                      = "canadacentral"
    name                          = "evhns-iactest-prod-sec"
    app_env                       = "prod"
    sku                           = "Premium"
    capacity                      = 1
    public_network_access_enabled = false
    identity_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-eventhub"
    ]

    customer_managed_key = {
      key_vault_key_ids = [
        "https://kv-iactest-prod-001.vault.azure.net/keys/cmk/00000000000000000000000000000000"
      ]
      infrastructure_encryption_enabled = true
      user_assigned_identity_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-eventhub"
    }

    network_rulesets = {
      default_action                 = "Deny"
      trusted_service_access_enabled = true
      ip_rules = [
        {
          ip_mask = "203.0.113.10"
        }
      ]
      virtual_network_rules = [
        {
          subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-eventhub"
        }
      ]
    }

    enable_private_endpoint    = true
    private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_dns_zone_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"
    ]

    disaster_recovery_config = {
      name                 = "evhns-iactest-dr"
      partner_namespace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.EventHub/namespaces/evhns-iactest-prod-sec2"
    }
  }

  assert {
    condition     = output.identity_type == "UserAssigned"
    error_message = "User-assigned identity should be enabled for CMK."
  }

  assert {
    condition     = output.private_endpoint_name == "pep-evhns-iactest-prod-sec"
    error_message = "Private endpoint name did not follow the standardized naming convention."
  }
}

run "plan_user_assigned_identity_capture" {
  command = plan

  variables {
    resource_group_name = "rg-ccoe-iac-cc-dev"
    location            = "canadacentral"
    name                = "evhns-iactest-prod-capture"
    sku                 = "Standard"

    identity_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-eventhub-capture"
    ]

    eventhubs = {
      telemetry = {
        capture_description = {
          enabled = true
          destination = {
            archive_name_format         = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
            blob_container_name         = "capture"
            storage_account_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-storage/providers/Microsoft.Storage/storageAccounts/stcapture"
            storage_authentication_type = "UserAssigned"
            storage_authentication_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-eventhub-capture"
          }
        }
      }
    }
  }

  assert {
    condition     = output.identity_type == "UserAssigned"
    error_message = "User-assigned identity Capture should attach the requested identity to the namespace."
  }
}
