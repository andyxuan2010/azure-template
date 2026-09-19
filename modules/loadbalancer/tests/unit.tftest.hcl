mock_provider "azurerm" {}

variables {
  name                = "lb-platform-prod"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }

  frontend_ip_configurations = [
    {
      name                 = "public"
      public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/publicIPAddresses/pip-platform"
    }
  ]

  backend_address_pools = [{ name = "application" }]

  probes = [
    {
      name         = "https"
      protocol     = "Https"
      port         = 443
      request_path = "/health"
    }
  ]

  lb_rules = [
    {
      name                           = "https"
      protocol                       = "Tcp"
      frontend_port                  = 443
      backend_port                   = 443
      frontend_ip_configuration_name = "public"
      backend_address_pool_name      = "application"
      probe_name                     = "https"
      disable_outbound_snat          = true
    }
  ]

  outbound_rules = [
    {
      name                           = "egress"
      backend_address_pool_name      = "application"
      frontend_ip_configuration_name = "public"
    }
  ]
}

run "plan" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Load Balancer name output did not match input."
  }

  assert {
    condition     = length(output.outbound_rule_ids) == 1
    error_message = "One outbound rule should be planned."
  }

  assert {
    condition     = output.tags.CostCenter == "platform"
    error_message = "Inherited resource-group tags were not applied."
  }
}
