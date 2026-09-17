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
