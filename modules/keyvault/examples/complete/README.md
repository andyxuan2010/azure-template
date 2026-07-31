# Complete Private Key Vault Example

Creates a hardened Key Vault with a private endpoint, direct private DNS zone ID, certificate contact, diagnostics, and optional admin/user group RBAC.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-prod" `
  -var="private_endpoint_subnet_id=/subscriptions/.../subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.vaultcore.azure.net" `
  -var="log_analytics_workspace_id=/subscriptions/.../workspaces/law-platform-prod" `
  -var="certificate_contact_email=platform@example.com"
```

Applying creates billable Key Vault, private endpoint, diagnostic, certificate-contact, and optional RBAC resources. Ensure private DNS links and management-path access exist.
