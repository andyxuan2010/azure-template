# Complete App Registration Example

Demonstrates a production-oriented single-tenant API and web sign-in application with:

- an owned service principal and duplicate-name protection;
- App Service Easy Auth and MSAL callbacks;
- one application role and one delegated permission scope;
- a pre-authorized client;
- token claims and durable application metadata;
- no client secret.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="pre_authorized_client_id=00000000-0000-4000-8000-000000000000"
```

Use the real client ID of an existing trusted application. Treat exposed role and scope GUIDs as durable API contracts. Applying modifies tenant directory state; confirm ownership, consent governance, redirect domains, and deletion controls first.
