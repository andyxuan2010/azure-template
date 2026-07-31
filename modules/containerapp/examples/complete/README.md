# Complete Container App Example

Creates a production-oriented HTTP API with multiple revisions, system-assigned identity, a Key Vault secret reference, a pinned caller-supplied image, HTTPS-only ingress, an IP allow rule, CORS, minimum capacity, and HTTP scaling.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-app-prod" `
  -var="container_app_environment_id=/subscriptions/.../providers/Microsoft.App/managedEnvironments/cae-app-prod" `
  -var="container_image=contoso.azurecr.io/api@sha256:..." `
  -var="key_vault_secret_id=https://kv-app-prod.vault.azure.net/secrets/api-token/..."
```

Grant the Container App identity access to the Key Vault secret and image registry. Replace the documentation-only CIDR, verify application authentication, review scale cost, and plan revision traffic changes before apply.
