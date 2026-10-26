# Complete Static Web App Example

Creates a Free-plan Static Web App with application settings, preview environments, public network access, inherited-tag handling, and a system-assigned managed identity. The example deliberately does not include a repository token or basic-auth password.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-platform-dev"
```

Configure repository integration separately with `repository_url`, `repository_branch`, and `repository_token` when the deployment workflow is ready. Treat the token as a secret and do not place it in source control.
