# Microsoft Entra Identity and Azure RBAC

Microsoft Entra identity objects and Azure Resource Manager (ARM) role assignments control different authorization planes. Keep their ownership and approvals explicit.

## Identity object model

- An **application registration** is the tenant's application definition. The `appregistration` module can create the application, optional service principal, API permissions, app roles/scopes, credentials, and federated identity credentials.
- An **enterprise application** is the service principal representing an application in a tenant. The `enterpriseapplication` module creates or adopts that principal and can manage app-role assignments. Its optional Application Proxy feature uses Microsoft Graph beta through the `msgraph` provider.
- A **managed identity** is an Azure-managed service principal for a workload. The `managedidentity` module creates a user-assigned identity and may add federated credentials and ARM role assignments.

Prefer workload identity federation or managed identity over long-lived client secrets where supported. When a credential is required, restrict its lifetime, access, storage, and rotation; never place secret values in source control.

## Federation and consent

Federated trust must match the identity provider's exact issuer, subject, and audience. A mismatch prevents token exchange; overly broad trust can allow unintended workloads to authenticate. Verify the trust subject against the intended repository, branch/environment, or Kubernetes service account.

OAuth delegated/application permissions and admin consent are Entra directory operations. Review requested permissions with the tenant owner. Consent is distinct from Azure RBAC and does not grant access to Azure resources.

## ARM role definitions and assignments

- `customrole` creates an Azure RBAC custom role definition; it does not assign it.
- `roleassignments` creates assignments for existing principals and roles at supplied management group, subscription, resource group, or resource scopes.
- `managedidentity` can create optional assignments for the identity it owns.

Use the narrowest useful scope and least privilege. A custom role's assignable scopes and allowed/excluded operations should be reviewed independently from the assignment. Existing assignments should have one Terraform owner or a deliberate import plan to avoid duplicate ownership.

## Review checklist

- Confirm the target tenant, principal type, object/client ID, and ownership before applying.
- Separate identity creation, application permission consent, and ARM RBAC review when approval boundaries differ.
- Validate issuer/subject/audience and principal IDs; avoid display-name-only assumptions.
- Confirm role actions, data actions, exclusions, assignment scope, conditions, and propagation expectations.
- Verify downstream identity permissions for Key Vault, registries, storage, and other data planes; ARM control-plane rights alone may not grant data access.
- Protect Terraform state because credentials and identity metadata may be stored there.

See the [appregistration](../../modules/app_registration/README.md), [enterpriseapplication](../../modules/enterprise_application/README.md), [managedidentity](../../modules/managed_identity/README.md), [customrole](../../modules/custom_role/README.md), and [roleassignments](../../modules/role_assignments/README.md) module guides, plus the [module dependency guide](../20-repository/module-usage-and-dependencies.md).

## Azure DevOps service connection identities

The [ACR connection](../../modules/ado_service_connection_acr/README.md) and [ARM connection](../../modules/ado_service_connection_azurerm/README.md) modules consume existing user-assigned identities and create workload federation trust using endpoint-returned issuer/subject values. They accept no client secrets, create no Azure RBAC assignments, and authorize no pipelines by default. Supply explicit pipeline IDs, distinct credential names, and separate identities for different privilege boundaries.

Governance owners remain responsible for endpoint administrators, approvals/branch checks, scoped Azure RBAC, state access, audit retention, and access reviews. A service connection's subscription/resource-group metadata does not restrict identity permissions. No module by itself establishes regulatory compliance.
