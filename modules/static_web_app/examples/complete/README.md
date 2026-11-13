# Complete Static Web App Example

Creates a Free-plan Static Web App with application settings, preview environments, public network access, inherited-tag handling, and a system-assigned managed identity. The example deliberately does not include a repository token or basic-auth password.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-platform-dev"
```

Configure repository integration separately with `repository_url`, `repository_branch`, and `repository_token` when the deployment workflow is ready. Treat the token as a secret and do not place it in source control.

## Cost and risk

- Billing: the module default `Free` SKU applies, which is free. Selecting `Standard` would be billed per app per month, plus bandwidth beyond the included quota. The system-assigned identity and app settings are free.
- Risk: `public_network_access_enabled = true` exposes the site to the internet, and preview environments are enabled, so each pull request can create a publicly reachable staging copy. No repository is connected, so no deployment token is stored. Destroying the app removes the site.
