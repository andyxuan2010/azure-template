# SQL Managed Instance Database Architecture and Ownership

```text
existing delegated subnet and network
                  |
                  v
      existing SQL Managed Instance
                  |
                  +--> managed database
                  |        |
                  |        +--> diagnostics --> Log Analytics
                  |
                  +--> parent-scope Reader RBAC

database scope ---> Contributor / Reader RBAC
```

## Ownership Boundary

The module owns one managed database, its optional diagnostic setting, and role assignments derived from the two group lists. The parent Managed Instance, its network, backups, identities, and platform configuration remain external.

Database ownership must be exclusive. Import an existing database or matching role assignments before adding them to this module.

## Access Boundary

Azure RBAC controls management-plane operations. It does not create SQL logins, users, schemas, or database-role membership. Manage data-plane authorization through a separate, auditable database deployment process.

The `administrator_login` output is inherited from the parent lookup and marked sensitive. Avoid using it as an application credential.

## Tag Boundary

When inheritance is enabled, tags come from the Managed Instance resource group rather than from the parent instance resource itself. Caller tags override inherited keys.

## Lifecycle

Creating or deleting the Terraform resource creates or deletes the managed database. Backup retention, point-in-time restore, long-term retention, and failover behavior are governed by the parent platform and separate configuration.

Before destructive changes, verify recoverability and application shutdown procedures. After creation, validate diagnostics and data-plane access independently.
