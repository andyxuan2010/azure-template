# Firewall Examples

## Zone-Redundant Hub Firewall

```hcl
module "firewall" {
  source = "../firewall"

  resource_group_name = "rg-network-prod"
  location            = "canadacentral"
  workload_name       = "hub"
  app_env             = "prod"
  subnet_id           = module.vnet.subnet_ids["AzureFirewallSubnet"]
  zones               = ["1", "2", "3"]

  enable_diagnostics         = true
  log_analytics_workspace_id = module.loganalytics.id
}
```

## Existing Public IPs

```hcl
module "firewall" {
  source = "../firewall"

  resource_group_name = "rg-network-prod"
  location            = "canadacentral"
  name                = "afw-hub-prod-cc-001"
  subnet_id           = module.vnet.subnet_ids["AzureFirewallSubnet"]
  create_public_ip    = false
  public_ip_ids       = [azurerm_public_ip.firewall.id]
}
```

## Rule Collection Groups

```hcl
module "firewall" {
  source = "../firewall"

  resource_group_name = "rg-network-prod"
  location            = "canadacentral"
  name                = "afw-hub-prod-cc-001"
  subnet_id           = module.vnet.subnet_ids["AzureFirewallSubnet"]

  rule_collection_groups = {
    workload = {
      priority = 200
      network_rule_collections = {
        allow_dns = {
          priority = 210
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
      application_rule_collections = {
        allow_web = {
          priority = 220
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
    }
  }
}
```

## Premium Policy

```hcl
module "firewall" {
  source = "../firewall"

  resource_group_name       = "rg-network-prod"
  location                  = "canadacentral"
  name                      = "afw-hub-prod-cc-001"
  sku_tier                  = "Premium"
  firewall_policy_sku       = "Premium"
  subnet_id                 = module.vnet.subnet_ids["AzureFirewallSubnet"]
  management_subnet_id      = module.vnet.subnet_ids["AzureFirewallManagementSubnet"]
  firewall_policy_identity_ids = [azurerm_user_assigned_identity.firewall_policy.id]

  policy_insights = {
    enabled                            = true
    default_log_analytics_workspace_id = module.loganalytics.id
    retention_in_days                  = 30
  }

  intrusion_detection = {
    mode = "Deny"
  }

  tls_certificate = {
    name                = "fw-tls"
    key_vault_secret_id = azurerm_key_vault_secret.firewall_tls.id
  }
}
```

## Virtual WAN Hub Firewall

```hcl
module "firewall" {
  source = "../firewall"

  resource_group_name         = "rg-network-prod"
  location                    = "canadacentral"
  name                        = "afw-vhub-prod-cc-001"
  sku_name                    = "AZFW_Hub"
  create_public_ip            = false
  virtual_hub_id              = azurerm_virtual_hub.hub.id
  virtual_hub_public_ip_count = 2
}
```
