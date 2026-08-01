# Basic FortiGate Example

Creates one private FortiGate VM with external-side and internal-side NICs in existing subnets. It creates no public IP and no inbound NSG rules.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-network-dev" `
  -var="admin_ssh_public_key=ssh-ed25519 ..." `
  -var="external_subnet_id=/subscriptions/.../subnets/snet-fortigate-external" `
  -var="internal_subnet_id=/subscriptions/.../subnets/snet-fortigate-internal"
```

Accept the Marketplace terms and confirm the BYOL entitlement or switch to matching PAYG image inputs before apply. Add UDRs and FortiOS configuration separately. A single appliance has no VM-level redundancy.
