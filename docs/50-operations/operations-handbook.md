# Operations Handbook

Use this page to route a failed pipeline or Terraform operation to the relevant runbook. Do not rerun an apply or change state until you know the target environment and current operation status.

## First-response checklist

1. Record repository, branch, commit, workflow run, environment, backend key, workspace, and approximate failure time.
2. Identify the failed job and first actionable error. Check whether an upstream gate intentionally skipped dependent jobs.
3. Confirm whether Terraform reached the plan or apply stage. A failed pipeline can still have partially changed cloud resources if failure occurred during apply.
4. Check for another active run or a valid state lock before retrying.
5. Escalate according to the owning team's incident process. This repository does not define an on-call rota or severity SLA.

## Common symptoms

| Symptom | First checks | Runbook |
| --- | --- | --- |
| Only the Terraform workflow gate runs | Check `IS_ORIGIN`; downstream jobs skip unless it is `true`. | [GitHub Actions Pipeline](../40-pipelines/github-actions-pipeline.md) |
| Azure-backed plan is skipped | Check the four Azure secrets, selected environment, and `TF_BACKEND_READY`. | [GitHub Actions Pipeline](../40-pipelines/github-actions-pipeline.md) |
| Apply is skipped | Check ref, event type, apply toggle/input, backend readiness, validation result, and environment approval. | [Environment Lifecycle](../30-deployment/environment-lifecycle.md) |
| Azure DevOps pipeline cannot start | Check agent-pool capacity and `ADO_AGENT_ENABLED`; inspect shared-runner hygiene setup. | [Azure DevOps Pipeline](../40-pipelines/azure-devops-pipeline.md), [Shared Runner Hygiene](../40-pipelines/shared-runner-hygiene.md) |
| Terraform reports a state lock | Verify whether an active run owns it. Force-unlock only a confirmed stale lock with owner approval. | [Terraform State and Recovery](terraform-state-and-recovery.md) |
| Apply failed or resources are partially changed | Stop concurrent runs, inspect Azure and state, preserve a protected backup, and create a fresh plan. | [Terraform State and Recovery](terraform-state-and-recovery.md) |
| A deletion is requested | Confirm the owning state, data retention, dependent resources, and complete destructive plan. | [Destroy a Resource](destroy-a-resource.md) |
| A publish job is skipped | Check destination variable and matching token/PAT; production/sandbox publishing also requires its enable variable. | [GitHub Actions Pipeline](../40-pipelines/github-actions-pipeline.md) |

## Recovery boundaries

- Do not reuse a binary plan after source, state, or cloud resources have changed.
- Do not hand-edit Terraform state JSON or upload it to tickets or chat.
- Do not force-unlock a state while an active Terraform process may still own the lock.
- Do not run `terraform destroy` for a single-resource removal from shared state.
- Use the [Terraform State and Recovery](terraform-state-and-recovery.md) and [Destroy a Resource](destroy-a-resource.md) procedures for state or deletion work.

## After recovery

Confirm the final state with a fresh plan, verify the affected Azure resources, capture the change or incident record, and update the relevant module or runbook if the incident exposed a documentation gap.

The repository documents the controls and procedures; it does not supply a support-hours commitment, incident severity matrix, or named on-call contacts. Obtain those from the service owner.
