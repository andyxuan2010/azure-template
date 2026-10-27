mock_provider "azurerm" {}

mock_provider "azuread" {}

mock_provider "random" {}

variables {
  resource_group_name           = "rg-platform-dev"
  location                      = "canadacentral"
  inherited_resource_group_tags = {}
  name                          = "sb-platform-dev-001"
  sku                           = "Standard"

  queues = {
    orders = {}
  }

  topics = {
    events = {}
  }

  subscriptions = {
    processor = {
      topic_name = "events"
    }
  }

  authorization_rules = {
    sender = {
      send = true
    }
  }

  tags = {
    Owner = "CCOE"
  }
}

run "plan_namespace_entities_and_tags" {
  command = plan

  assert {
    condition     = output.name == var.name && length(output.queue_ids) == 1 && length(output.topic_ids) == 1 && length(output.subscription_ids) == 1
    error_message = "Service Bus namespace or messaging entities were not planned correctly."
  }

  assert {
    condition     = output.merged_tags.Owner == "CCOE" && !contains(keys(output.merged_tags), "Environment")
    error_message = "Service Bus must preserve caller tags without generating implicit tags."
  }
}

run "plan_premium_private_endpoint_diagnostics_and_rbac" {
  command = plan

  variables {
    sku                          = "Premium"
    capacity                     = 1
    premium_messaging_partitions = 1
    enable_private_endpoint      = true
    private_endpoint_subnet_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-private-endpoints"
    private_dns_zone_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"
    enable_diagnostics           = true
    log_analytics_workspace_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/log-platform"
    app_admin_group              = ["11111111-1111-1111-1111-111111111111"]
    app_user_group               = ["22222222-2222-2222-2222-222222222222"]
  }

  assert {
    condition     = length(azurerm_private_endpoint.this) == 1 && length(azurerm_monitor_diagnostic_setting.this) == 1
    error_message = "Private endpoint and diagnostics should be planned when enabled."
  }

  assert {
    condition     = length(output.app_admin_group_role_assignment_ids) == 1 && length(output.app_user_group_role_assignment_ids) == 1
    error_message = "Expected Contributor and Reader role assignments."
  }
}

run "reject_basic_topics" {
  command = plan

  variables {
    sku = "Basic"
  }

  expect_failures = [
    check.servicebus_input_consistency,
  ]
}

run "reject_unknown_subscription_topic" {
  command = plan

  variables {
    subscriptions = {
      invalid = {
        topic_name = "missing"
      }
    }
  }

  expect_failures = [
    check.servicebus_input_consistency,
  ]
}

run "reject_invalid_manage_rule" {
  command = plan

  variables {
    authorization_rules = {
      invalid = {
        manage = true
      }
    }
  }

  expect_failures = [
    check.servicebus_input_consistency,
  ]
}
