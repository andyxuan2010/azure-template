# Basic Container App Example

Creates a small externally reachable Container App in an existing managed environment.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-app-dev" `
  -var="container_app_environment_id=/subscriptions/.../providers/Microsoft.App/managedEnvironments/cae-app-dev"
```

Applying the example creates billable Container Apps resources. The public sample image and external ingress are for evaluation; pin an approved image, add application authentication, and review the environment's network controls before production use.
