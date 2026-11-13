# GitHub OIDC Managed Identity Example

Creates a managed identity that trusts workflows from one protected GitHub environment in one repository. It creates no Azure role assignments.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-platform-prod" `
  -var="github_repository=contoso/platform"
```

Configure GitHub environment protection, then use the output client and tenant IDs with the repository's Azure login action. Add least-privilege RBAC separately or through the module after review.

## Cost and risk

- Free: the user-assigned identity and its federated credential have no charge, and no role assignment or other billable resource is created.
- Risk: the credential trusts tokens from `https://token.actions.githubusercontent.com` whose subject is `repo:<repository>:environment:<environment>`. Anyone who can run a job in that environment can obtain a token for this identity, so enforce GitHub environment protection and required reviewers. The subject must match exactly (case and environment name), or logins fail; changing it replaces the credential. This example sets `inherit_resource_group_tags` to its default, so resource group tags are inherited and the group must exist and be readable. The identity has no access until you add RBAC, and recreating it breaks any role assignment made elsewhere.
