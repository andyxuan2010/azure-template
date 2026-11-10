# Microsoft Entra Easy Auth Example

Creates a publicly reachable Linux Web App protected by App Service built-in Microsoft Entra authentication. Anonymous access is denied, and the client secret is referenced through an App Service Key Vault reference rather than supplied as plaintext.

Before planning, register `https://<app-name>.azurewebsites.net/.auth/login/aad/callback`, place the secret in Key Vault, and grant the Web App identity permission to read it.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-dev" `
  -var="app_service_plan_id=/subscriptions/.../serverfarms/asp-orders-dev" `
  -var="active_directory_client_id=00000000-0000-4000-8000-000000000000" `
  -var="client_secret_key_vault_uri=https://kv-orders.vault.azure.net/secrets/app-auth/<version>"
```

Applying changes billable App Service configuration. Public traffic is allowed so the sign-in callback can operate, but every request is subject to Easy Auth. This example does not create the app registration, secret, Key Vault access, or redirect URI; manage those dependencies explicitly and rotate credentials through the approved secret process.
