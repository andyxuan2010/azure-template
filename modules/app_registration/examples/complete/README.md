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

## Cost and risk

- Entra app registrations, roles, scopes and service principals are free, so no billable resource is created.
- Duplicate names are blocked and the current caller is added as an owner. The app role and delegated scope use fixed GUIDs; changing or removing them breaks clients already granted them. The pre-authorized client skips user consent for the scope, so use only a trusted client ID. Redirect URIs derived from the App Service hostnames must match real hosts. Deleted applications go to the Entra recycle bin.
