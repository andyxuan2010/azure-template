# Terraform State and Recovery

Terraform state maps configuration to managed Azure objects and can include sensitive values. Treat backend access, local state, plan files, and state backups as protected data.

## Backend readiness

`dev` and `sandbox` backend files contain configured values. Confirm the storage account, container, key, tenant, subscription, permissions, network access, locking, retention, and recovery protections with the platform owner before initializing. `prod/backend.hcl` contains all-zero tenant/subscription IDs and TODO resource/storage names; it is a template placeholder and must not be used.

This repository does not prove that storage versioning, soft delete, or point-in-time recovery is enabled. Verify those safeguards in Azure before relying on them.

## Routine operations

Use the correct environment backend and variable file, and inspect the selected workspace and state key before planning. The standard root harness is the Terraform root; do not initialize an unrelated module directory against the shared environment state.

```powershell
terraform init -reconfigure -backend-config="environments/<environment>/backend.hcl"
terraform plan -var-file="<environment>.tfvars"
```

Use the actual approved variable file configured for the environment. Keep local state, state backups, generated plans, credentials, and Terraform logs out of source control and shared artifacts unless specifically approved and protected.

## Recovery workflow

1. Stop concurrent runs and identify the exact backend, key, workspace, commit, and last operation. Check whether another valid Terraform process still owns the state lock.
2. Securely preserve a state backup using the approved storage process before any repair. Limit access and delete temporary copies under the organization's retention rules.
3. Inspect configuration, Azure resources, and state together. Prefer Terraform `moved` or `import` blocks for reviewed ownership changes. Use `terraform state mv`, `rm`, or `import` only as a controlled, documented state repair with a reviewed recovery plan.
4. After a partial apply, refresh understanding with a new plan and reconcile the actual cloud state. Never reapply an old binary plan after configuration, state, or infrastructure has changed.
5. Use `terraform force-unlock` only when the lock is confirmed stale, its owner is no longer operating, and the responsible team approves. Record the lock ID and reason.
6. Verify the resulting plan and resources, then document the recovery in the normal change record.

Do not hand-edit state JSON or upload state to tickets, chat, or unapproved storage.

## Deletion and teardown

Remove an individual resource through its owning Terraform configuration and reviewed plan. A full `terraform plan -destroy` is appropriate only for an isolated state whose complete teardown is approved. Review data retention, soft-delete, backup, dependent resources, and shared-state impact before applying. See [Destroy a Resource](destroy-a-resource.md).
