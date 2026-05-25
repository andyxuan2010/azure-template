# Microsoft Entra ID authentication example

This example creates an Azure Web App with built-in **Microsoft Entra ID (formerly Azure AD)** authentication enabled through the App Service module.

## What it does

- Provisions a Log Analytics workspace (external module) and an App Service Plan (external module).
- Creates a Linux Web App using the local appservice module with:
  - **Entra ID authentication** via `auth_settings_v2.active_directory_v2`.
  - Required sign-in by default (`require_authentication = true` in module behavior).
  - App setting placeholder for the Entra app registration client secret (recommended with Key Vault reference).

## Files

- `main.tf` – Provider, random ID, log analytics and app service plan modules, and the appservice (web app) module with Entra auth.
- `variables.tf` – Input variables including `active_directory_client_id`.

## Usage

1. **App registration**: In Microsoft Entra ID, create an app registration and configure redirect URI:
   `https://<your-app>.azurewebsites.net/.auth/login/aad/callback`.
2. **Client secret**: Create a client secret and store it securely (recommended: Azure Key Vault).
3. **Implicit/hybrid + ID token**: If your sign-in flow requires implicit/hybrid grants, enable access token and ID token issuance on the app registration. If you create the app registration using this repository's `modules/appregistration`, both are enabled by default.
4. **Set variables** (for example in `terraform.tfvars`):

   ```hcl
   resource_group_name = "rg-myapp-dev"
   location            = "canadacentral"
   active_directory_client_id = "00000000-0000-0000-0000-000000000000"

   # Optional overrides:
   # active_directory_client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
   # active_directory_tenant_auth_endpoint = "https://login.microsoftonline.com/<tenant-id>/v2.0"
   # active_directory_login_parameters = { domain_hint = "contoso.com" }
   ```

5. Ensure the app setting referenced by `active_directory_client_secret_setting_name` is populated (prefer Key Vault references).
6. From this example directory run:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Module variables used

| Variable | Purpose |
|----------|---------|
| `active_directory_client_id` | Required. Application (client) ID of the Microsoft Entra app registration used for login. |
| `active_directory_client_secret_setting_name` | Optional. App setting name that holds the client secret; default is `MICROSOFT_PROVIDER_AUTHENTICATION_SECRET`. |
| `active_directory_tenant_auth_endpoint` | Optional. Tenant-specific auth endpoint; omit to use the current tenant. |
| `active_directory_login_parameters` | Optional. Additional query parameters sent to the Entra auth endpoint during login. |

See the root module `variables.tf` for complete descriptions.

## Notes

- The example uses external modules for Log Analytics and App Service Plan; adjust `source` and versions as needed.
- Ensure the app registration redirect URI matches your Web App URL (`https://<app-name>.azurewebsites.net/.auth/login/aad/callback`).
- Do not store secrets in source control. Use Key Vault references or equivalent secret injection patterns.
