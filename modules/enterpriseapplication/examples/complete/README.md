# Complete Enterprise Application Example

Composes the standardized app registration and Enterprise Application modules. It creates an OIDC web app registration, gives the Enterprise Application controlled launch metadata, and requires explicit assignment before sign-in.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

Replace the example homepage and redirect URI with registered production URLs. This composition intentionally prevents the app registration module from also owning the service principal.

## Cost and risk

- Free: it creates an Entra app registration and service principal only. No Azure (ARM) resources are created, so there is no per-hour, per-GB or per-request charge, even though the `azurerm` provider is declared.
- Risk: both objects are tenant-wide directory changes, so creation and deletion are visible to every tenant administrator. The deploying identity becomes owner of the service principal. `app_role_assignment_required = true` blocks sign-in for users who have no assignment (this example creates no assignments), and `preferred_single_sign_on_mode = "oidc"` and `login_url` should match the app registration redirect URIs. Deleting the app registration also invalidates the service principal; Entra soft-deletes applications for 30 days.
