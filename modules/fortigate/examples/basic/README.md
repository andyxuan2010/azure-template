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

## Cost and risk

- One Linux VM (`Standard_F4s_v2` by default) is billed per hour for compute, plus the Premium_LRS OS disk per GB, and each NIC and NSG is free. With the default `byol` license type the FortiGate software licence is billed through your Fortinet entitlement, not by Azure; a PAYG image instead adds a per-hour software charge to the VM. No load balancer or public IP is created in this example, so there is no load-balancer or public-IP charge.
- Risk: a single appliance has no VM-level redundancy, and any VM size, zone, image or primary-NIC change can replace the VM and interrupt all traffic through it. The Marketplace plan must be accepted in the subscription first, or the deployment fails. Subnet NSG associations and exposed management ports depend on the NSG rules the module applies; review them before pointing routes at the appliance.
