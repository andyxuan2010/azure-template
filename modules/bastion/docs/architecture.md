# Azure Bastion Architecture

```text
User / Azure portal
        |
        v
  Standard static public IP (module-created or caller-owned)
        |
        v
  Azure Bastion host
        |
        v
  Dedicated AzureBastionSubnet (/26 or larger)
        |
        v
  Private VM addresses in the VNet
```

## Ownership Boundary

The module owns the Bastion host and, by default, one Standard static public IP. When `public_ip_address_id` is supplied, the public IP remains caller-owned. The VNet and `AzureBastionSubnet` are always caller-owned dependencies.

## Network Requirements

The subnet must be named exactly `AzureBastionSubnet`, be dedicated to Bastion, have an address prefix of `/26` or larger, and be in the same resource group as the host. Bastion host creation joins the supplied subnet. If an NSG or route table is attached, it must follow the current Azure Bastion network guidance for the selected SKU and features.

The module does not inspect the subnet prefix or NSG configuration. A syntactically valid subnet ID is not proof that Azure will accept the subnet.

## Public IP and Lifecycle

Public Basic, Standard, and Premium deployments require a Standard static public IP. The module creates one unless an existing public IP ID is supplied. Bring-your-own public IP must be in the same region, meet the SKU/allocation requirements, and not be in use by another resource.

The host and its public IP can take several minutes to provision. Replacing the host or changing immutable deployment characteristics can interrupt administrative access. Keep a second controlled access path available during production changes.

## Cost and Scale

Bastion is billed for provisioned host time and data transfer. Standard and Premium can use scale units from 2 through 50. Basic remains at two. Choose a SKU and scale appropriate to expected connection concurrency and required features, then monitor usage and cost.
