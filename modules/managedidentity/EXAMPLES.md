# Managed Identity Examples

## Identity With GitHub OIDC Credential

```hcl
module "github_identity" {
  source = "../managedidentity"

  name                = "id-github-prod-001"
  resource_group_name = "rg-platform-prod"
  location            = "eastus"

  federated_identity_credentials = {
    github_main = {
      audience = ["api://AzureADTokenExchange"]
      issuer   = "https://token.actions.githubusercontent.com"
      subject  = "repo:contoso/platform:ref:refs/heads/main"
    }
  }
}
```
