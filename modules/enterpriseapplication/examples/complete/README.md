# Complete Enterprise Application Example

Composes the standardized app registration and Enterprise Application modules. It creates an OIDC web app registration, gives the Enterprise Application controlled launch metadata, and requires explicit assignment before sign-in.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

Replace the example homepage and redirect URI with registered production URLs. This composition intentionally prevents the app registration module from also owning the service principal.
