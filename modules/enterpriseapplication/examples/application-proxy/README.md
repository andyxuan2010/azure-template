# Enterprise Application Proxy Example

Configures Microsoft Entra Application Proxy on an existing app registration through Microsoft Graph beta. It requires explicit user assignment, Entra preauthentication, secure cookies, backend certificate validation, and Continuous Access Evaluation.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="application_id=00000000-0000-0000-0000-000000000000" `
  -var="internal_url=https://intranet.contoso.local/" `
  -var="external_url=https://intranet-contoso.msappproxy.net/"
```

The URLs are illustrative. Confirm connector availability, internal DNS and TLS trust, external URL ownership, Conditional Access, backend authentication, and beta API compatibility before deployment.
