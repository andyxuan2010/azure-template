# Role Assignments Module

Create reusable RBAC assignments at management group, subscription, resource group, or resource scope.

This module normalizes assignment inputs, resolves principal and role-definition IDs, generates deterministic role assignment names, and rejects duplicate logical assignments.

Declared assignments are managed directly by Terraform, so repeated `terraform plan` and `terraform apply` runs stay stable for resources already in state. If a matching role assignment already exists outside Terraform state, import it before applying this module to avoid duplicate-assignment conflicts.

See also:

- [EXAMPLES.md](EXAMPLES.md)
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- [IDEMPOTENCY.md](IDEMPOTENCY.md)
