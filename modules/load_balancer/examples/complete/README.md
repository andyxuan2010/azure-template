# Complete Public Load Balancer Example

Creates a Standard public Load Balancer with an HTTPS health probe, TCP/443 load-balancing rule, explicit outbound rule, and an empty backend pool.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-prod" `
  -var="public_ip_address_id=/subscriptions/.../publicIPAddresses/pip-orders-prod"
```

The caller must associate backend NICs and allow probe/application traffic in NSGs and guest firewalls. Applying creates a billable Load Balancer and can affect egress design.
