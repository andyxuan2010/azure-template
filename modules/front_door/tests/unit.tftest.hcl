mock_provider "azurerm" {}

variables {
  name                        = "afd-platform-dev-001"
  endpoint_name               = "afd-platform-dev-001"
  resource_group_name         = "rg-edge-dev"
  origin_hostname             = "app.example.net"
  inherit_resource_group_tags = false
  tags = {
    Owner = "CCOE"
  }
}

run "plan_standard_https_frontdoor" {
  command = plan

  assert {
    condition     = output.profile_name == var.name && output.sku_name == "Standard_AzureFrontDoor"
    error_message = "The Front Door profile name or Standard tier was not propagated."
  }

  assert {
    condition     = azurerm_cdn_frontdoor_endpoint.this.name == var.endpoint_name && output.tags.Owner == "CCOE"
    error_message = "The Front Door endpoint name or caller tags were not propagated."
  }

  assert {
    condition     = azurerm_cdn_frontdoor_route.this.forwarding_protocol == "HttpsOnly" && azurerm_cdn_frontdoor_route.this.https_redirect_enabled
    error_message = "The route must forward with HTTPS and redirect HTTP to HTTPS by default."
  }
}

run "plan_premium_private_link" {
  command = plan

  variables {
    sku_name = "Premium_AzureFrontDoor"
    private_link = {
      private_link_target_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app/providers/Microsoft.Web/sites/app-example"
      location               = "canadacentral"
      target_type            = "sites"
    }
  }

  assert {
    condition     = output.sku_name == "Premium_AzureFrontDoor" && length(azurerm_cdn_frontdoor_origin.this.private_link) == 1
    error_message = "Premium Private Link origin settings were not propagated."
  }
}

run "reject_private_link_on_standard_tier" {
  command = plan

  variables {
    private_link = {
      private_link_target_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app/providers/Microsoft.Web/sites/app-example"
      location               = "canadacentral"
    }
  }

  expect_failures = [
    azurerm_cdn_frontdoor_origin.this,
  ]
}

run "reject_https_redirect_without_http_listener" {
  command = plan

  variables {
    supported_protocols = ["Https"]
  }

  expect_failures = [
    azurerm_cdn_frontdoor_route.this,
  ]
}
