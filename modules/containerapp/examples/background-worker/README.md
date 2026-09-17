# Background Worker Container App Example

Creates an internal background worker with no ingress. A user-assigned managed identity authenticates to an Azure Storage queue and a KEDA-compatible custom rule scales replicas from zero.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-worker-prod" `
  -var="container_app_environment_id=/subscriptions/.../providers/Microsoft.App/managedEnvironments/cae-worker-prod" `
  -var="container_image=contoso.azurecr.io/worker@sha256:..." `
  -var="worker_identity_id=/subscriptions/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-worker-prod" `
  -var="storage_account_name=stworkerprod"
```

Grant the identity registry pull permission and least-privileged queue data access. Confirm the managed environment can resolve and reach the registry and storage endpoint.
