# Basic Internal Load Balancer Example

Creates a Standard internal Load Balancer with one static frontend and one empty backend pool. The caller must associate backend NICs or addresses separately.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-dev" `
  -var="frontend_subnet_id=/subscriptions/.../subnets/snet-application" `
  -var="frontend_private_ip_address=10.20.1.10"
```

Applying creates a billable Load Balancer. Confirm the static IP is available and plan backend membership, probes, rules, and NSGs before serving traffic.
