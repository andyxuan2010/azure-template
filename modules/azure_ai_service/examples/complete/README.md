# Complete Azure AI Services Example

Creates a private `AIServices` account with a system-assigned identity, project management, diagnostics, a responsible AI policy, a model deployment, and optional workload RBAC.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-ai-prod" `
  -var="private_endpoint_subnet_id=/subscriptions/.../virtualNetworks/vnet-ai-prod/subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.cognitiveservices.azure.com" `
  -var="log_analytics_workspace_id=/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/log-platform-prod"
```

Before apply, replace the illustrative global name and verify the private DNS zone for the selected account kind. Confirm that the model name, version, SKU, capacity, quota, and responsible AI settings are currently supported in the target region. Model deployments and diagnostic ingestion are billable.
