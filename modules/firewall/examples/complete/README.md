# Complete Azure Firewall Example

Creates a production-oriented zone-redundant Standard firewall with two public IPs, policy rule collections for approved HTTPS and Azure DNS, diagnostics, and optional operator RBAC.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-network-prod" `
  -var="azure_firewall_subnet_id=/subscriptions/.../virtualNetworks/vnet-hub-prod/subnets/AzureFirewallSubnet" `
  -var="log_analytics_workspace_id=/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/log-platform-prod"
```

The example rules are illustrative. Review rule scope, FQDN dependencies, UDRs, SNAT, return paths, DNS proxy client settings, zone support, cost, and log retention before apply.
