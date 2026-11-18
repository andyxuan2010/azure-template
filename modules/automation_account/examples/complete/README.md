# Complete Private Automation Account Example

Demonstrates a production-oriented Automation Account with:

- local and public access disabled;
- system-assigned identity plus a user-assigned encryption identity;
- customer-managed key encryption;
- Webhook and DSC/Hybrid Worker private endpoints;
- private DNS association and Log Analytics diagnostics;
- optional Entra group RBAC and a least-privilege target-scope assignment.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-operations-prod" `
  -var="private_endpoint_subnet_id=/subscriptions/.../subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.azure-automation.net" `
  -var="log_analytics_workspace_id=/subscriptions/.../workspaces/log-platform-prod" `
  -var="encryption_identity_id=/subscriptions/.../userAssignedIdentities/id-automation-encryption" `
  -var="key_vault_key_id=/subscriptions/.../vaults/kv-platform/keys/automation/<version>"
```

Applying creates Automation, private endpoint, diagnostic, encryption, and optional RBAC resources. Confirm Key Vault cryptographic permissions, key rotation policy, identity ownership, DNS VNet links, Hybrid Worker connectivity, subnet policies, access recovery, costs, and cleanup.
