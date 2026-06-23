# FortiGate Module

Deploy reusable FortiGate-VM architectures on Microsoft Azure.

The module supports:

- `single`: one private FortiGate VM for a POC or test deployment.
- `active-passive`: two FortiGate VMs with zone placement, optional internal
  and external Standard Load Balancers, and extensible HA/management NICs.
- Existing subnet IDs or optional creation of dedicated subnets in an existing
  VNet.
- BYOL or PAYG image/plan inputs.
- Static or dynamic private IP addressing per interface.
- Optional NSG creation and subnet association.
- Private load balancer frontends by default.
- Explicit opt-in for an external public load balancer frontend.

## Security Defaults

- No public IP is created unless
  `external_load_balancer.create_public_ip = true`.
- No NSG rules are created by default.
- Accelerated networking is disabled by default.
- Management access is private by default.
- An administrator password or SSH public key is required.
- Public administration is not implemented by the module.

## Current Single-VM Design

![Single private FortiGate architecture](docs/images/fortigate-poc-current-architecture.png)

This profile creates one FortiGate VM with caller-defined interfaces. The
typical POC mapping uses external and internal private subnets.

```hcl
module "fortigate" {
  source = "../template/modules/fortigate"

  architecture       = "single"
  resource_group_name = "rg-ba-cc-prod-hub-network"
  location            = "canadacentral"
  name_prefix         = "fgt-ba-cc-prod-vfirewall"

  admin_username       = "azureuser"
  admin_ssh_public_key = var.fortigate_admin_ssh_public_key

  interfaces = {
    external = {
      role       = "external"
      subnet_id  = module.vnet.subnet_ids["snet-vfirewall-external"]
      primary    = true
      private_ip_addresses = {
        a = "10.32.192.4"
      }
    }
    internal = {
      role      = "internal"
      subnet_id = module.vnet.subnet_ids["snet-vfirewall-internal"]
      private_ip_addresses = {
        a = "10.32.193.4"
      }
    }
  }
}
```

## Recommended Active-Passive Design

![Active-passive FortiGate target architecture](docs/images/fortigate-production-target-architecture.png)

The HA profile creates two FortiGate VMs. It can attach their external and
internal NICs to Standard Load Balancer backend pools and supports dedicated HA
and management interfaces.

```hcl
module "fortigate" {
  source = "../template/modules/fortigate"

  architecture        = "active-passive"
  resource_group_name = "rg-network-prod"
  location            = "canadacentral"
  name_prefix          = "fgt-hub-prod"

  availability_zones = {
    a = "1"
    b = "2"
  }

  load_balancer_frontend_zones = ["1", "2", "3"]

  admin_ssh_public_key = var.fortigate_admin_ssh_public_key

  interfaces = {
    external = {
      role      = "external"
      subnet_id = module.vnet.subnet_ids["snet-fortigate-external"]
      primary   = true
      private_ip_addresses = {
        a = "10.20.0.4"
        b = "10.20.0.5"
      }
    }
    internal = {
      role      = "internal"
      subnet_id = module.vnet.subnet_ids["snet-fortigate-internal"]
      private_ip_addresses = {
        a = "10.20.1.4"
        b = "10.20.1.5"
      }
    }
    ha = {
      role                  = "ha"
      subnet_id             = module.vnet.subnet_ids["snet-fortigate-ha"]
      enabled_architectures = ["active-passive"]
      associate_nsg         = false
      private_ip_addresses = {
        a = "10.20.2.4"
        b = "10.20.2.5"
      }
    }
    management = {
      role      = "management"
      subnet_id = module.vnet.subnet_ids["snet-fortigate-management"]
      private_ip_addresses = {
        a = "10.20.3.4"
        b = "10.20.3.5"
      }
    }
  }

  internal_load_balancer = {
    enabled             = true
    interface_name      = "internal"
    frontend_ip_address = "10.20.1.10"
  }

  external_load_balancer = {
    enabled             = true
    interface_name      = "external"
    create_public_ip    = false
    frontend_ip_address = "10.20.0.10"
  }
}
```

## Creating Dedicated Subnets

Set `create_subnets = true` to create dedicated FortiGate subnets inside an
existing VNet. Each interface then supplies `subnet_name` and
`address_prefixes` instead of `subnet_id`.

```hcl
module "fortigate" {
  source = "../template/modules/fortigate"

  architecture                        = "single"
  resource_group_name                 = "rg-network-prod"
  location                            = "canadacentral"
  create_subnets                      = true
  virtual_network_name                = "vnet-hub-prod"
  virtual_network_resource_group_name = "rg-network-prod"

  admin_ssh_public_key = var.fortigate_admin_ssh_public_key

  interfaces = {
    external = {
      role             = "external"
      subnet_name      = "snet-fortigate-external"
      address_prefixes = ["10.20.0.0/24"]
      primary          = true
      private_ip_addresses = {
        a = "10.20.0.4"
      }
    }
    internal = {
      role             = "internal"
      subnet_name      = "snet-fortigate-internal"
      address_prefixes = ["10.20.1.0/24"]
      private_ip_addresses = {
        a = "10.20.1.4"
      }
    }
  }
}
```

## Architecture Behavior

| Capability | `single` | `active-passive` |
|---|---:|---:|
| VM count | 1 | 2 |
| Instance suffixes | `a` | `a`, `b` |
| Zone spread | Optional | Per-instance zone map |
| External/internal NICs | Caller-defined | Caller-defined |
| HA NIC | Optional | Recommended |
| Management NIC | Optional | Recommended |
| Internal load balancer | Ignored | Optional |
| External load balancer | Ignored | Optional |
| Public frontend | Off | Explicit opt-in |

## Important Boundaries

This module provisions Azure infrastructure. It does not configure:

- FortiOS firewall policies, static routes, BGP, or SD-WAN.
- FGCP cluster membership, heartbeat, session synchronization, or licensing.
- UDRs between workloads and the internal load balancer.
- Load balancer probe response inside FortiOS.
- FortiManager or FortiAnalyzer resources.
- Marketplace terms acceptance.

For HA, provide FortiOS bootstrap configuration through `custom_data` or manage
the appliances with FortiManager. Validate health probes, symmetric routing,
failover, return paths, and rollback before directing production traffic.
Set `load_balancer_frontend_zones` only when the target region supports the
selected zones; its default is a regional frontend with no zone list.

## Image and License Selection

The defaults use the Fortinet BYOL image:

```hcl
image = {
  publisher = "fortinet"
  offer     = "fortinet_fortigate-vm_v5"
  sku       = "fortinet_fg-vm"
  version   = "latest"
}
```

For PAYG or a pinned image, set `license_type`, `image`, and
`marketplace_plan` together. Confirm the current image URN and accept its Azure
Marketplace terms before deployment.

## Validation

```powershell
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test
```

The test suite uses `mock_provider "azurerm"` and performs plan-only assertions;
it does not create Azure resources.

From the repository root, generate the same focused override used by CI:

```bash
bash scripts/azure-pipelines/module-harness-targets.sh overrides \
  --module fortigate \
  --output fortigate.auto.tfvars.json
terraform plan -input=false
```

## References

- [Fortinet: HA for FortiGate-VM on Azure](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/azure-administration-guide/983245/ha-for-fortigate-vm-on-azure)
- [Microsoft: Deploy highly available NVAs](https://learn.microsoft.com/azure/architecture/networking/guide/network-virtual-appliance-high-availability)
- [Microsoft: Azure Load Balancer HA Ports](https://learn.microsoft.com/azure/load-balancer/load-balancer-ha-ports-overview)
