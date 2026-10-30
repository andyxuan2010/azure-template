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

## Cost and risk

- The service principal, app-role assignment requirement and Graph update are free as Entra objects; there is no per-resource Azure charge. Application Proxy itself is a licensed Entra feature (billed through tenant licensing per user, not per request), and the connector servers you run are billed as ordinary compute.
- Risk: this example updates the existing app registration's `onPremisesPublishing` settings through Microsoft Graph beta, so it changes an object you may not own. `app_role_assignment_required = true` with `aadPreAuthentication` blocks sign-in for anyone not assigned, so assign users before cutover. The internal and external URLs, connector group reachability and backend TLS validation must be correct or the published app will be unavailable; removing the proxy block does not necessarily clear the settings (`ignore_missing_property = true`).
