# Function App Architecture

This module selects one Function App resource from two independent dimensions:

| Dimension | Choices | Effect |
|---|---|---|
| Operating system | Linux or Windows | Selects the AzureRM Function App resource and valid runtime settings. |
| Storage authentication | Access key/Key Vault secret or managed identity | Selects how the Functions host reaches its required storage account. |

Exactly one of the four resulting Function App resources is created. Outputs normalize their common attributes so callers do not need to know which internal resource was selected.

## Dependency Flow

```text
Resource group ───────────────────────────────┐
App Service Plan ─────────────────────────────┤
Storage account or Key Vault secret ──────────┼─> Function App
VNet integration subnet (optional) ───────────┤       │
Private endpoint subnet + DNS (optional) ─────┘       ├─> diagnostic setting
Log Analytics / Storage / Event Hub (optional) ───────┘
```

The module does not create the App Service Plan, storage account, networking, DNS zone, or monitoring destinations.

## Network Flows

- Regional VNet integration controls outbound traffic from the Function App.
- A private endpoint controls inbound access to the Function App.
- The two features require separate subnets with different delegation requirements.
- Private DNS must resolve the app hostname to the private endpoint from every consuming network.
- The Function runtime must still reach its storage account; private app access alone does not secure or enable that storage path.

## Identity and Secrets

Managed identity is the preferred storage and downstream-service authentication model. Role assignments for the storage account, Key Vault, registry, or application dependencies remain part of the root composition.

Key-based inputs, connection strings, app settings, and auth configuration are represented in Terraform and may be retained in state. Use an encrypted, access-controlled remote backend and avoid plain-text secrets.

## Replacement Boundaries

Operating-system changes, incompatible plan changes, names, and some networking or runtime changes can replace the Function App. Keep stable names and isolate application deployments from infrastructure changes where appropriate.
