# Enterprise Application Complete Example

This example creates an app registration with `modules/appregistration`, then connects a dedicated Enterprise Application using `modules/enterpriseapplication`.

## What It Does

- Creates a Microsoft Entra app registration.
- Creates or reuses the linked Enterprise Application service principal.
- Configures OIDC launch settings.
- Optionally configures Microsoft Entra Application Proxy.

## Usage

```powershell
terraform init
terraform plan
```

To include Application Proxy:

```powershell
terraform plan -var="create_application_proxy=true"
```

## Notes

- Application Proxy uses Microsoft Graph beta `onPremisesPublishing`.
- Keep `create_service_principal = false` in the app registration module when this module owns the Enterprise Application.
- Use real internal and external URLs before applying the proxy example.
