# Basic Application Gateway Example

Creates a Standard_v2 Application Gateway with one public HTTP listener, one backend pool, and one basic routing rule.

This low-complexity example is intended for learning and non-production validation. It does not configure TLS, WAF, diagnostics, or private ingress. The default backend address is from a documentation-only range and must be replaced.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-platform-dev" `
  -var="subnet_id=/subscriptions/.../virtualNetworks/vnet-platform-dev/subnets/snet-application-gateway"
```

Application Gateway and its public IP are billable if applied. Confirm subnet sizing, backend reachability, NSGs, routes, and cleanup ownership first.
