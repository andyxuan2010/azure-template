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

## Cost and risk

- Container Apps bill per vCPU-second and GiB-second of replica time (0.5 vCPU and 1Gi per replica here) and per request, with a monthly free grant. With min_replicas 0 there is no idle replica charge, but up to 20 replicas can run under load, so max_replicas sets the cost ceiling. The environment is created outside this example.
- Scale to zero means a cold-start delay when messages arrive. The queue scaler authenticates with the user-assigned identity, so missing queue data permission leaves the app stuck at zero, and missing registry pull rights make revisions fail to start. Single revision mode replaces the running revision on each change.
