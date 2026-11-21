# Dedicated Network FortiGate Example

Creates a dedicated VNet, external and internal subnets, and one private FortiGate VM. The module owns the network lifecycle in this isolated sandbox pattern.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-fortigate-sbx" `
  -var="admin_ssh_public_key=ssh-ed25519 ..."
```

Module-owned networking expands the destroy and replacement blast radius. Add peering, UDRs, FortiOS configuration, and monitoring separately, and do not copy the sample address plan into a shared environment without IPAM review.

## Cost and risk

- One Linux VM (`Standard_F4s_v2` by default) is billed per hour, plus its Premium_LRS OS disk per GB and the FortiGate licence (BYOL by default, outside Azure; PAYG images add a per-hour charge). The virtual network, subnets, NICs and NSGs this example creates are free, though traffic leaving the VNet (egress, peering) is billed per GB.
- No load balancer or public IP is created here, so none of their charges apply.
- Risk: the module owns the VNet and subnets (`create_virtual_network` and `create_subnets`), so destroying or replacing it removes the network along with the appliance, and changing the address space or subnet prefixes can force replacement of dependent NICs and the VM. The sample `10.30.0.0/22` range can overlap existing networks and block later peering.
