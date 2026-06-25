# Managed Identity Examples

## Identity With GitHub OIDC Credential

```hcl
module "github_identity" {
  source = "./modules/managedidentity"

  name                = "id-github-prod-001"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"

  federated_identity_credentials = {
    github_main = {
      audience = ["api://AzureADTokenExchange"]
      issuer   = "https://token.actions.githubusercontent.com"
      subject  = "repo:contoso/platform:ref:refs/heads/main"
    }
  }
}
```

## Identity With Role Assignment By ID

```hcl
role_assignments = {
  reader = {
    scope              = "/subscriptions/<subscription-id>/resourceGroups/rg-platform-prod"
    role_definition_id = "/subscriptions/<subscription-id>/providers/Microsoft.Authorization/roleDefinitions/<role-id>"
  }
}
```

Each assignment sets exactly one of `role_definition_name` or
`role_definition_id`.
