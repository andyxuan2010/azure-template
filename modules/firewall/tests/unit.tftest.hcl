mock_provider "azurerm" {}

mock_provider "azuread" {}

variables {
  name                = "afw-platform-prod-001"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  app_env             = "prod"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod/subnets/AzureFirewallSubnet"
  zones               = ["1", "2", "3"]

  app_admin_group = []
  app_user_group  = []

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_named_vnet_firewall_baseline" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Azure Firewall test name was not propagated to the module."
  }

  assert {
    condition     = output.firewall_policy_sku == "Standard"
    error_message = "Firewall Policy should inherit the Standard firewall SKU by default."
  }

  assert {
    condition     = output.public_ip_count == 1
    error_message = "Default VNet firewall should create one Standard public IP."
  }

  assert {
    condition     = output.tags.Owner == "CCOE" && output.tags.IaC == "Terraform" && !contains(keys(output.tags), "ManagedBy") && !contains(keys(output.tags), "module") && !contains(keys(output.tags), "name") && !contains(keys(output.tags), "app_env") && !contains(keys(output.tags), "Environment")
    error_message = "Firewall should preserve caller tags without adding module-generated tags."
  }
}

run "reject_mismatched_created_policy_sku" {
  command = plan

  variables {
    sku_tier            = "Standard"
    firewall_policy_sku = "Premium"
  }

  expect_failures = [
    check.firewall_input_consistency,
  ]
}

run "reject_ipv6_public_ip" {
  command = plan

  variables {
    public_ip_version = "IPv6"
  }

  expect_failures = [
    check.firewall_input_consistency,
  ]
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-platform-dev"
    location                    = "canadacentral"
    name                        = ""
    name_prefix                 = "afw"
    workload_name               = "hub"
    app_env                     = "poc"
    include_environment_in_name = true
    location_code               = "cc"
    instance                    = "001"
    use_random_suffix           = false
    subnet_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-dev/providers/Microsoft.Network/virtualNetworks/vnet-hub-dev/subnets/AzureFirewallSubnet"
    zones                       = []
    app_admin_group             = []
    app_user_group              = []
  }

  assert {
    condition     = output.name == "afw-hub-poc-cc-001"
    error_message = "Generated deterministic firewall name did not match the expected naming convention."
  }

  assert {
    condition     = output.location_code == "cc"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_policy_rules_diagnostics_and_rbac" {
  command = plan

  variables {
    name                = "afw-platform-prod-rules"
    resource_group_name = "rg-platform-prod"
    location            = "canadacentral"
    app_env             = "prod"
    subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod/subnets/AzureFirewallSubnet"
    public_ip_count     = 2

    rule_collection_groups = {
      workload = {
        priority = 200
        application_rule_collections = {
          allow_platform = {
            priority = 210
            action   = "Allow"
            rules = {
              microsoft = {
                source_addresses  = ["10.10.0.0/16"]
                destination_fqdns = ["*.microsoft.com"]
                protocols = [
                  {
                    type = "Https"
                    port = 443
                  }
                ]
              }
            }
          }
        }
        network_rule_collections = {
          allow_dns = {
            priority = 220
            action   = "Allow"
            rules = {
              dns = {
                source_addresses      = ["10.10.0.0/16"]
                destination_addresses = ["168.63.129.16"]
                destination_ports     = ["53"]
                protocols             = ["TCP", "UDP"]
              }
            }
          }
        }
        nat_rule_collections = {
          publish_https = {
            priority = 230
            action   = "Dnat"
            rules = {
              app = {
                source_addresses    = ["203.0.113.10"]
                destination_address = "198.51.100.10"
                destination_ports   = ["443"]
                translated_address  = "10.20.1.10"
                translated_port     = "8443"
                protocols           = ["TCP"]
              }
            }
          }
        }
      }
    }

    app_admin_group = ["11111111-1111-1111-1111-111111111111"]
    app_user_group  = ["22222222-2222-2222-2222-222222222222"]

    role_assignments = {
      reader = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        principal_type       = "Group"
        role_definition_name = "Reader"
      }
    }

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-prod/providers/Microsoft.OperationalInsights/workspaces/log-platform-prod"
    log_analytics_destination_type = "Dedicated"
  }

  assert {
    condition     = output.public_ip_count == 2
    error_message = "Expected two firewall public IP IDs."
  }

  assert {
    condition     = output.rule_collection_group_count == 1
    error_message = "Expected one rule collection group."
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

run "plan_premium_forced_tunneling_and_policy_features" {
  command = plan

  variables {
    name                 = "afw-platform-prod-prem"
    resource_group_name  = "rg-platform-prod"
    location             = "canadacentral"
    app_env              = "prod"
    sku_tier             = "Premium"
    firewall_policy_sku  = "Premium"
    subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod/subnets/AzureFirewallSubnet"
    management_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod/subnets/AzureFirewallManagementSubnet"

    dns_servers                       = ["10.0.0.4"]
    firewall_policy_identity_ids      = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-prod/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-firewall-policy"]
    auto_learn_private_ranges_enabled = true

    policy_insights = {
      enabled                            = true
      default_log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-prod/providers/Microsoft.OperationalInsights/workspaces/log-platform-prod"
      retention_in_days                  = 30
    }

    intrusion_detection = {
      mode = "Deny"
      traffic_bypass = [
        {
          name                  = "trusted-monitoring"
          protocol              = "TCP"
          source_addresses      = ["10.10.1.0/24"]
          destination_addresses = ["10.20.1.10"]
          destination_ports     = ["443"]
        }
      ]
    }

    tls_certificate = {
      name                = "fw-tls"
      key_vault_secret_id = "https://kv-platform-prod.vault.azure.net/secrets/fw-tls/00000000000000000000000000000000"
    }
  }

  assert {
    condition     = output.sku_tier == "Premium" && output.firewall_policy_sku == "Premium"
    error_message = "Premium firewall and policy SKUs should be planned."
  }

  assert {
    condition     = output.management_ip_configuration_enabled == true
    error_message = "Forced tunneling should plan a management public IP."
  }
}

run "plan_virtual_hub_firewall" {
  command = plan

  variables {
    name                        = "afw-platform-prod-vhub"
    resource_group_name         = "rg-platform-prod"
    location                    = "canadacentral"
    app_env                     = "prod"
    sku_name                    = "AZFW_Hub"
    subnet_id                   = ""
    create_public_ip            = false
    virtual_hub_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualHubs/vhub-prod"
    virtual_hub_public_ip_count = 2
  }

  assert {
    condition     = output.sku_name == "AZFW_Hub"
    error_message = "Virtual Hub firewall should use AZFW_Hub."
  }

  assert {
    condition     = output.public_ip_count == 0
    error_message = "Virtual Hub firewall should not create VNet public IP resources."
  }
}
