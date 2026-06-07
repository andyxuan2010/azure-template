# NSG Module

Provision an Azure Network Security Group with inline security rules and optional subnet or NIC associations.

## Overview

- Providers: `azurerm`
- Use case: subnet segmentation, workload ingress/egress control, platform network guardrails
- Terraform tests: `tests/live.tftest.hcl`

## Basic Usage

```hcl
module "web_nsg" {
  source = "./modules/nsg"

  name                = "nsg-web-prod-001"
  resource_group_name = "rg-example-prod"
<<<<<<< HEAD
  location            = "canadacentral
=======
  location            = "canadacentral"
>>>>>>> 44e292bab739e0c498f116b8675868ad3eeb41c0

  security_rules = {
    allow_https_in = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
```

## Proper Usage

- Manage subnet associations here only if the NSG module owns the binding lifecycle.
- Keep priorities unique within the NSG.
- Prefer explicit subnet IDs from the `vnet` module output instead of manual lookup strings.

## Dependencies

- Required: existing resource group
- Common upstream: `rg`, `vnet`
- Common downstream: `linuxvm`, `winvm`, private endpoint subnets

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
