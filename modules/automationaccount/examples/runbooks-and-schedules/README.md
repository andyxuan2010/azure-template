# Runbooks and Schedules Example

Creates an inline PowerShell 7.2 runbook, daily UTC schedule, job association, and non-sensitive typed Automation variables.

The runbook is intentionally harmless and must be replaced through code review. Real runbooks should use managed identity, narrowly scoped RBAC, structured logging, idempotent operations, bounded retries, and tested failure handling.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-operations-dev"
```

Set `schedule_start_time` to a future RFC3339 timestamp before apply. Applying creates executable automation and a schedule; confirm time zone, ownership, change approval, identity permissions, state sensitivity, execution cost, monitoring, rollback, and cleanup.
