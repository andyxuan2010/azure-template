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
