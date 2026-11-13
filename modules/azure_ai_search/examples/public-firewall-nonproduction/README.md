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

## Cost and risk

- Basic SKU Azure AI Search is billed per search-unit hour, where units are replicas times partitions (1 each by default), and it bills for as long as the service exists, even when idle. Semantic ranking is not configured here.
- Public network access is on, restricted to the allowed_ips list, with API-key authentication disabled; callers must use Entra ID, and the system-assigned identity needs data-plane roles on any data sources. A wrong IP list locks callers out. Not suitable for production.
- The service name is globally unique, and changing the SKU tier can force replacement.
