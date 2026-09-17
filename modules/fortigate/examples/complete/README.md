# Complete FortiGate Example

Creates two zone-distributed FortiGate VMs with external, internal, HA, and management interfaces plus private internal and external Standard Load Balancers. Public frontend creation remains disabled.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-network-prod" `
  -var="admin_ssh_public_key=ssh-ed25519 ..." `
  -var="external_subnet_id=/subscriptions/.../subnets/snet-fortigate-external" `
  -var="internal_subnet_id=/subscriptions/.../subnets/snet-fortigate-internal" `
  -var="ha_subnet_id=/subscriptions/.../subnets/snet-fortigate-ha" `
  -var="management_subnet_id=/subscriptions/.../subnets/snet-fortigate-management"
```

Before apply, confirm Marketplace licensing, zone and VM quota, static address availability, route tables, NSGs, probe design, and FortiOS HA bootstrap. Azure infrastructure alone does not form a functioning HA pair.
