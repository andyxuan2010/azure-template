# Logic App Standard Architecture

The module creates the Logic App Standard host and connects it to existing compute, storage, network, and monitoring services.

```text
Workflow Standard App Service Plan ───────────┐
Storage account + Azure Files content ────────┼─> Logic App Standard host
VNet integration subnet (optional) ───────────┤          │
Private endpoint subnet + DNS (optional) ─────┘          ├─> diagnostic setting
Log Analytics workspace (optional) ──────────────────────┘
```

Workflow definitions and API connections are deployed separately through an application delivery process.

## Storage Boundary

Logic App Standard requires a storage account for host state and content. This module reads the existing storage account access key and supplies it to the Logic App resource. The key and any caller-provided connection strings are therefore present in Terraform state.

When VNet integration or private endpoints are used, the Logic App must still resolve and reach the required blob, file, queue, and table endpoints. Storage firewalls, private endpoints, DNS zones, and routing are outside this module.

## Network Flows

- VNet integration controls outbound traffic from the Logic App host.
- Route-all sends supported outbound traffic through the integrated subnet.
- The integration subnet must satisfy App Service delegation and capacity requirements.
- The Logic App private endpoint controls inbound access and uses the `sites` subresource.
- Integration and private endpoint subnets must be separate.
- `privatelink.azurewebsites.net` must resolve correctly for private clients.

## Identity and Connections

The host can receive system-assigned and user-assigned identities. Connector and downstream-service permissions remain caller-owned.

Managed API connections, OAuth grants, secrets, and workflow connection metadata are not created here. Prefer managed identity and Key Vault references where connector support allows them.

## Deployment Boundary

Infrastructure changes manage the host. Workflow code, artifacts, connection configuration, testing, and release promotion should use a separate pipeline with its own rollback and approval model.
