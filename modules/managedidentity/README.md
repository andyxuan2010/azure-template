# Azure User-Assigned Managed Identity

Provisions one user-assigned managed identity with optional workload identity federation and Azure RBAC assignments.

## Features

- Creates a user-assigned managed identity with generated or explicit naming.
- Creates multiple federated identity credentials for OIDC trust.
- Supports GitHub Actions, Azure DevOps workload identity federation, AKS workload identity, and other compatible issuers.
- Creates optional Azure role assignments at caller-supplied scopes.
- Supports role selection by built-in name or full role definition ID.
- Inherits resource-group tags and lets caller tags take precedence.

## Resources Created

- One user-assigned managed identity.
- Zero or more federated identity credentials.
- Zero or more Azure role assignments for that identity.

The resource group and every role-assignment scope are existing dependencies.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- Existing resource group.
- Exact issuer, audience, and subject values from the external OIDC platform.
- `Microsoft.Authorization/roleAssignments/write` permission at every requested scope.

Create the identity before workloads such as AKS, Function App, App Service, or Automation Account reference its resource or client ID.

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

## Basic Usage

```hcl
module "workload_identity" {
  source = "./modules/managedidentity"

  name                = "id-orders-prod-001"
  resource_group_name = "rg-orders-prod"
  location            = "canadacentral"
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)
- [`examples/github-oidc`](examples/github-oidc/)

## Federation Security

Federated identity credentials do not contain a secret. Azure validates the token issuer, audience, and subject against the configured trust:

- use the narrowest subject supported by the issuer;
- pin GitHub trust to the intended repository and branch, tag, pull-request, or environment subject;
- use the exact Kubernetes service-account subject for AKS workload identity;
- never reuse a broad subject across unrelated workloads.

Issuer and subject changes alter the trust boundary and should receive the same review as a credential rotation.

## Role Assignment Ownership

Create role assignments here only when this module should own their lifecycle. Each assignment must select exactly one of `role_definition_name` or `role_definition_id`.

Prefer the narrowest resource scope and least-privilege role. RBAC propagation is eventually consistent, so immediate consumer operations can fail briefly after apply.

## Naming and Tagging

Set `name` explicitly for predictable references or use the workload, environment, location, and instance naming inputs. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider with plan-only and expected-failure runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

No Azure resources are deployed by these tests.

## Known Limitations

- The module creates one identity per invocation.
- It does not configure the external OIDC issuer, GitHub environment, Azure DevOps service connection, Kubernetes service account, or AKS annotation.
- It does not create custom role definitions.
- Plan-only tests cannot verify live token exchange or RBAC propagation.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment metadata retained for interface compatibility. | `string` | `"dev"` | no |
| <a name="input_federated_identity_credentials"></a> [federated\_identity\_credentials](#input\_federated\_identity\_credentials) | Map of federated identity credentials keyed by credential name. | <pre>map(object({<br>    audience = list(string)<br>    issuer   = string<br>    subject  = string<br>  }))</pre> | `{}` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into managed identity resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the managed identity. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Optional user-assigned managed identity name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the managed identity will be created. | `string` | n/a | yes |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Map of role assignments keyed by assignment name. | <pre>map(object({<br>    scope                = string<br>    role_definition_name = optional(string)<br>    role_definition_id   = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the managed identity. | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | The managed identity client ID. |
| <a name="output_federated_identity_credential_ids"></a> [federated\_identity\_credential\_ids](#output\_federated\_identity\_credential\_ids) | Federated identity credential resource IDs keyed by credential name. |
| <a name="output_id"></a> [id](#output\_id) | The managed identity resource ID. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to the managed identity. |
| <a name="output_name"></a> [name](#output\_name) | The managed identity name. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The managed identity principal ID. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Role assignment IDs keyed by assignment name. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the managed identity. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The managed identity tenant ID. |
<!-- END_TF_DOCS -->
