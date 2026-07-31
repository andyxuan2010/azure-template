# Complete Application Gateway Example

Demonstrates a production-oriented WAF_v2 gateway with HTTPS, a hardened SSL policy, zone redundancy, autoscaling, health probes, path-based routing, WAF Prevention mode, diagnostics, and production tags.

## Usage

Supply existing network and monitoring dependencies plus certificate material through a secure input path:

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-platform-prod" `
  -var="subnet_id=/subscriptions/.../subnets/snet-application-gateway" `
  -var="log_analytics_workspace_id=/subscriptions/.../workspaces/log-platform-prod" `
  -var="ssl_certificate_data=<base64-pfx>" `
  -var="ssl_certificate_password=<pfx-password>"
```

Do not place certificate values on shared command histories in real workflows. Use protected environment variables or an approved secret-injection path, and protect Terraform state because it contains the PFX and password.

Application Gateway is billable and WAF, zones, and autoscaling increase cost. Replace the documentation-only backend addresses and verify regional zone support, DNS, subnet capacity, NSGs, routes, certificate ownership, and cleanup before apply.
