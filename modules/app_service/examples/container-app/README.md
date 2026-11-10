# Linux Container Web App Example

Creates a Linux Web App that runs a container image. The default image is public. For a private Azure Container Registry, enable managed-identity registry access and grant the emitted principal `AcrPull` at the registry scope.

The module's default unmatched IP action is `Deny`; add reviewed ingress rules or private connectivity before expecting the container endpoint to be reachable.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-dev" `
  -var="app_service_plan_id=/subscriptions/.../serverfarms/asp-orders-dev"
```

Pin production images by immutable digest or reviewed release tag. Applying creates a billable Web App; confirm plan OS, registry network access, image provenance, identity role assignment, and cleanup.
