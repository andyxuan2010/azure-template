# Public Firewall Azure AI Search Example

Creates a non-production Search service with public network access restricted to an IPv4 allowlist. Local authentication remains disabled and a system-assigned identity is enabled.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-search-dev" `
  -var='allowed_ips=["198.51.100.10/32"]'
```

The defaults use documentation-only IP space and must be replaced. Public access increases exposure: use a private endpoint for production unless an approved exception and compensating controls exist. IP filtering does not replace Entra authentication, least privilege, or monitoring.
