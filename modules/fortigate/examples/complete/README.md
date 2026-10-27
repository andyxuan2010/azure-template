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

## Cost and risk

- Two Linux VMs (`Standard_F4s_v2` by default) run continuously, so compute is billed per hour for both, plus a Premium_LRS OS disk per GB for each. FortiGate licences (BYOL by default) are billed outside Azure for each instance, or per hour on a PAYG image.
- Two Standard load balancers (internal and external) are billed per hour for their rules and per GB of data processed. `create_public_ip = false`, so the external load balancer uses a private frontend and no public IP charge applies; NICs and NSGs are free.
- Risk: the VMs are pinned to availability zones, so zone or VM-size quota shortages fail the apply, and changing zones, NIC IPs or image replaces a VM. Floating IP and HA-ports rules plus probe port 8008 must match the FortiOS configuration, or traffic will be dropped or fail over incorrectly. Pointing UDRs at the internal frontend routes production traffic through these appliances, so cutover mistakes cause outages.
