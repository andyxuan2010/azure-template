# Role Assignments Module

Create reusable RBAC assignments at management group, subscription, resource group, or resource scope.

This module normalizes assignment inputs, resolves principal and role-definition IDs, generates deterministic role assignment names, and rejects duplicate logical assignments.

Each assignment must provide exactly one role selector (`role_definition_name` or `role_definition_id`) and exactly one principal selector (`principal_name` or `principal_id`). Conditional assignments must provide both `condition` and `condition_version = "2.0"`.

Declared assignments are managed directly by Terraform, so repeated `terraform plan` and `terraform apply` runs stay stable for resources already in state. If a matching role assignment already exists outside Terraform state, import it before applying this module to avoid duplicate-assignment conflicts.

See also:

- [EXAMPLES.md](EXAMPLES.md)
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- [IDEMPOTENCY.md](IDEMPOTENCY.md)

## Testing

The test suite uses mocked providers and plan-only runs; it does not create Azure role assignments.

```powershell
terraform init -backend=false
terraform test -filter='tests\live.tftest.hcl'
```
