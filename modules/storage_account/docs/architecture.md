# Storage Account Architecture

## Scope

The module owns one Storage account and selected account-scoped data services, network controls, private endpoints, diagnostic settings, identities, and role assignments. The caller owns the resource group, network, private DNS zones and links, key resources, monitoring destinations, and workload data lifecycle.

## Resource Flow

```text
resource group
    |
    v
storage account
 |      |       |          |
data  network  identity   diagnostics
items  rules     + RBAC
                  |
      private endpoints ---- existing subnet
             |
        existing DNS zones
```

Containers, shares, queues, and tables depend on the Storage account. Network rules are managed as a separate AzureRM resource. Each requested storage subresource creates a distinct private endpoint and optional private DNS zone group.

## Provider Boundaries

The default AzureRM provider manages the Storage account and its dependent resources. `azurerm.prod` resolves private DNS zones by name, supporting a shared DNS subscription. Direct zone IDs avoid that lookup but do not remove the alias from the module contract. AzureAD resolves group names when object IDs are not supplied.

## Security and Lifecycle

The default data-plane posture is private: public access is disabled and network rules deny unmatched traffic. This does not create connectivity by itself; private endpoints, DNS links, routing, and a privately connected Terraform runner remain external dependencies.

Account kind, replication, hierarchical namespace, NFS/SFTP, encryption, immutability, and some service properties can be replacement-sensitive or constrained by one another. Review Azure limitations and protect business data before applying structural changes.

Automatic execution-identity and administrator RBAC is operationally convenient but broad. Disable it when centralized access governance owns role assignments.
