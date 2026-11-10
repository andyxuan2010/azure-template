# Azure DevOps Azure Resource Manager Service Connection

Provisions a Azure Resource Manager connection for Terraform and Azure deployments, workload identity federation trust on an existing user-assigned managed identity, and optional explicit pipeline authorizations. No passwords or client secrets are accepted.

## Features

- Uses workload identity federation exclusively.
- Composes with caller-owned identities, registries, and Azure RBAC.
- Grants access only to named pipeline IDs; no pipeline is authorized by default.
- Uses provider-returned issuer and subject values, including Microsoft Entra issuers.

## Resources Created

- One azuredevops_serviceendpoint_azurerm service connection.
- One AzureRM federated identity credential on the supplied managed identity.
- One Azure DevOps pipeline authorization per supplied pipeline ID.

No identities, projects, pipelines, registries, or Azure role assignments are created by the module. The complete example adds one scoped role assignment in its caller and establishes it before provisioning the connection and pipeline authorization. RBAC propagation may still require time before first use.

## Prerequisites and Dependencies

Terraform 1.7+, Azure DevOps Services with workload federation, an existing project and user-assigned managed identity, and reviewed Azure permissions for the workload. Pass matching identity resource/client/tenant IDs from [managed_identity](../managed_identity/README.md) outputs. Existing pipeline IDs must belong to the selected project. Use one identity per workload/environment privilege boundary.

The bootstrap identity needs Azure DevOps service connection creation/administration and pipeline authorization permissions, and federated credential write/delete access on the supplied Azure identity. Example role creation additionally requires role-assignment write/delete at the target scope. It must be a separate, already-working authentication path.

## Provider Configuration

Configure providers in the calling root. AzureRM manages the identity trust; microsoft/azuredevops manages project service connections and pipeline authorization, capabilities not covered by AzureRM. Both provider requirements are bounded stable major versions; no aliases are required. Configure AzureRM for the supplied identity's subscription and tenant, even when the target workload is in another subscription. Azure DevOps must target the intended organization.

```hcl
provider "azuredevops" {
  org_service_url = var.organization_url
}
provider "azurerm" {
  features {}
  subscription_id = var.identity_subscription_id
}
```

Supply provider authentication through supported environment/CI identity settings. Prefer federation; if a bootstrap PAT is unavoidable, use minimal service-connection permissions, short expiration, a secret store, and rotation. Never commit tokens, provider credentials, plans, or state.

## Basic Usage

```hcl
module "connection" {
  source = "./modules/ado_service_connection_azurerm"
  project_id = var.project_id
  name = "sc-example-azurerm"
  managed_identity = {
    id = module.identity.id
    client_id = module.identity.client_id
    tenant_id = module.identity.tenant_id
  }
  subscription_name = var.subscription_name
  pipeline_ids = { workload = var.pipeline_id }
  federated_credential_name = "ado-azurerm"
  subscription_id = var.subscription_id
}
```

Executable roots: [examples/basic](examples/basic/) for trust with existing RBAC, and [examples/complete](examples/complete/) for caller-owned scoped RBAC. Review costs and permissions in each example before applying.

## Important Behavior and Secure Defaults

Authentication is fixed to workload federation and the Azure token-exchange audience. Federation follows the endpoint's returned issuer/subject; do not hard-code legacy Azure DevOps issuers or subjects. Renaming or replacing a connection can change its trust; review the plan and pause affected pipelines during migration. Federated credential names must be unique on an identity; explicit names must be distinct when sharing one identity across connections. When omitted, the credential name is generated deterministically from the project and service connection name, with a module-specific prefix. The effective name is exposed as an output.

Pipeline IDs are unique positive integers in a map with stable keys, so IDs may be unknown until apply. The module never creates an all-pipelines authorization. Before production use, configure service connection approvals, branch control and required-template checks using its ID, then authorize reviewed pipelines. An authorization is not a substitute for these checks. Review existing project permissions and inherited/manual grants; this module does not revoke grants it does not own.

The service connection is subscription scoped. Azure RBAC is the enforcement boundary: grant the identity access at the deployment resource group or narrower scope. The provider does not permit resource-group endpoint metadata with manually supplied federated identity credentials. Use the output name for AzureCLI@2 azureSubscription, or a Terraform task that supports workload federation. The module does not configure Terraform provider or backend authentication for the consuming pipeline.

Use separate plan/apply identities when required, a reviewed custom role or resource-group-scoped Contributor for deployments, and separate role-assignment administration. Terraform's AzureRM backend generally also needs Storage Blob Data Contributor on the state container, plus network reachability. Avoid subscription Owner and blanket User Access Administrator grants. Never bootstrap this connection using the same connection before it exists.

## Networking and Private Connectivity

The module creates no network resources. Bootstrap execution needs access to Azure DevOps, Azure Resource Manager, and identity endpoints. Deployment agents need reachability to target APIs, private endpoints, state storage, and required DNS. Federation does not bypass storage or workload firewalls.

## Identity and RBAC

Identity lifecycle and workload Azure RBAC remain caller-owned, following [Entra Identity and RBAC](../../docs/60-security-governance/entra-identity-and-rbac.md). The module verifies input shapes; it cannot prove that supplied identity IDs correspond to the same object or tenant. No Entra application lookup or application creation occurs. Grant workload rights before use and allow for RBAC propagation. Trust creation and Azure DevOps authorization do not themselves grant Azure control-plane or data-plane rights.

## Naming and Tagging

Service connection names are explicit. Follow the [naming convention](../../docs/60-security-governance/naming-convention.md). Service connections, pipeline authorizations, and federated credentials do not expose ARM tags. Use the description for ownership/context and apply the [tagging standard](../../docs/60-security-governance/tagging-standard.md) to the caller-owned identity and workload resources.

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM and Azure DevOps providers with plan-only runs. No cloud authentication, network connectivity to Azure, resources, or cloud costs are required; initialization downloads providers. It covers secretless authentication, isolated default access, explicit pipeline selection, duplicate/null/negative pipeline rejection, generated credential names, target metadata, and input validation. `tests/federation.tftest.hcl` additionally runs an apply against fully mocked providers to verify the exact issuer/subject wiring and authorization target. Both providers are mocked in that file; no Azure or Azure DevOps API calls, credentials, resources, or cloud costs are involved, and Terraform cleans up the mock state.

```powershell
terraform -chdir=modules/ado_service_connection_azurerm init -backend=false
terraform -chdir=modules/ado_service_connection_azurerm validate
terraform -chdir=modules/ado_service_connection_azurerm test
```

CI runs the mocked tests and validates both examples with Terraform 1.7.5 and 1.15.8. No live integration test is included. Perform a reviewed apply and task smoke test in a nonproduction project before production adoption.

### Upgrading credential naming

The original default was `ado-service-connection`. To keep an existing credential unchanged when upgrading, explicitly set `federated_credential_name = "ado-service-connection"`. Otherwise the generated default changes the credential name and can replace the trust. Review the plan and schedule any trust migration before upgrading a connection used by active pipelines. Explicitly supplied names keep their existing behavior.

## Known Limitations

Only existing user-assigned managed identities in the target tenant and Azure DevOps Services are supported. Secret authentication, automatic identity creation, management-group endpoints, sovereign-cloud configuration, and all-pipeline grants are unsupported. Workload RBAC, approvals/checks, branch protection, audit-log retention, image scanning/signing, and organization policy remain separate governance controls; this module alone does not certify compliance.

Existing connections and trust credentials require import before Terraform ownership. Import the endpoint with project-ID/service-endpoint-ID and the federated credential with its ARM resource ID. Removing the module deletes its connection, trust and managed pipeline grants and interrupts pipelines, while leaving the caller-owned identity/RBAC intact. Protect remote state and review access periodically.

See [architecture and lifecycle](docs/architecture.md), [Microsoft service connection guidance](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops), and the [provider resource reference](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_azurerm).

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0, < 2.0.0 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | >= 1.15.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | >= 1.15.0, < 2.0.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azuredevops_pipeline_authorization.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/pipeline_authorization) | resource |
| [azuredevops_serviceendpoint_azurerm.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/serviceendpoint_azurerm) | resource |
| [azurerm_federated_identity_credential.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/federated_identity_credential) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Service connection description for ownership and operational context. | `string` | `"Managed by Terraform - CCOE"` | no |
| <a name="input_federated_credential_name"></a> [federated\_credential\_name](#input\_federated\_credential\_name) | Optional explicit federated credential name, unique within the identity. Null generates a deterministic name from the project and connection name. | `string` | `null` | no |
| <a name="input_managed_identity"></a> [managed\_identity](#input\_managed\_identity) | Existing user-assigned managed identity resource ID, client ID, and tenant ID; all must identify the same identity. | <pre>object({<br>    id        = string<br>    client_id = string<br>    tenant_id = string<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Explicit service connection name used in Azure Pipelines task inputs. | `string` | n/a | yes |
| <a name="input_pipeline_ids"></a> [pipeline\_ids](#input\_pipeline\_ids) | Explicit existing pipeline IDs keyed by stable caller-defined names. Empty grants no pipeline access; all-pipeline authorization is unsupported. | `map(number)` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Existing Azure DevOps project UUID. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Target Azure subscription UUID. Actual deployment permissions are controlled by caller-owned Azure RBAC. | `string` | n/a | yes |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | Display name of the target Azure subscription. This metadata does not grant Azure access. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | Managed identity client ID used by the connection. |
| <a name="output_federated_credential_name"></a> [federated\_credential\_name](#output\_federated\_credential\_name) | Effective federated credential name, explicit or deterministically generated. |
| <a name="output_federated_identity_credential_id"></a> [federated\_identity\_credential\_id](#output\_federated\_identity\_credential\_id) | Federated trust resource ID. |
| <a name="output_id"></a> [id](#output\_id) | Azure DevOps service connection ID. |
| <a name="output_name"></a> [name](#output\_name) | Service connection name for task inputs. |
| <a name="output_pipeline_authorization_ids"></a> [pipeline\_authorization\_ids](#output\_pipeline\_authorization\_ids) | Explicit pipeline authorizations keyed by caller-supplied names. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | Azure DevOps project ID. |
| <a name="output_workload_identity_federation_issuer"></a> [workload\_identity\_federation\_issuer](#output\_workload\_identity\_federation\_issuer) | Issuer returned by Azure DevOps; do not construct this value manually. |
| <a name="output_workload_identity_federation_subject"></a> [workload\_identity\_federation\_subject](#output\_workload\_identity\_federation\_subject) | Subject returned by Azure DevOps; do not construct this value manually. |
<!-- END_TF_DOCS -->
