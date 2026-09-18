# SQL Database Architecture and Security Boundaries

```text
applications
    |
    v
Private DNS ---> Private Endpoint ---> SQL logical server ---> database
                                          |                    |
                                          |                    +--> backup / audit / threat controls
                                          |
                                          +--> Entra administrator
                                          +--> managed identity ---> Key Vault key
                                          +--> Azure RBAC

database diagnostics ------------------------------> monitoring destination
primary server/database <--------------------------> failover partner
```

## Ownership Boundary

The module owns one logical server, one database, and the optional policies and child resources declared for them. It does not own shared networking, DNS, monitoring destinations, identities, Key Vault keys, secrets, elastic pools, or partner servers.

Avoid managing the same server firewall rules, auditing policies, Private Endpoint, database, or role assignments in another state.

## Authentication Boundary

Microsoft Entra administration controls administrative identity at the logical server. Entra-only mode removes SQL administrator configuration from the server resource. Azure RBAC controls Azure resource management, while database access still requires SQL principals and database roles managed through a database deployment process.

When SQL authentication, Key Vault credential lookup, import, audit storage, or threat detection keys are used, sensitive values can enter state. State encryption, access control, logging, and retention are part of the security boundary.

## Network Boundary

The Private Endpoint connects to the `sqlServer` subresource. Private DNS is required so clients resolve the server FQDN to the private address. Public access, firewall rules, DNS links, hybrid forwarding, and client routing must be evaluated together.

## Encryption and Identity

Server-level and database-level customer-managed keys have separate identity and permission requirements. Create and authorize the identities before applying the keys. Key rotation and recovery procedures must be tested outside Terraform plan validation.

## Resilience Boundary

Backup retention protects database recovery points. A failover group coordinates servers but does not validate application retry behavior, connection-string listener usage, recovery objectives, or planned-failover procedures.

## Recommended Sequence

1. Create the resource group, identities, keys, endpoint subnet, Private DNS, and monitoring destinations.
2. Deploy the logical server and database with Entra administration.
3. Validate auditing, diagnostics, backups, and database access.
4. Validate private DNS and connectivity.
5. Disable public and local authentication paths.
6. Add failover only after the secondary server and operational runbook are ready.
