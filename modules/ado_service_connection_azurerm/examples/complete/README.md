# ado_service_connection_azurerm: complete

Uses an existing Azure DevOps project and user-assigned managed identity. Targets an existing subscription for Terraform and Azure deployment tasks.

## Prerequisites

Terraform 1.7+, Azure DevOps Services with workload federation, authenticated AzureRM and Azure DevOps providers, permission to manage service connections/pipeline authorization and federated credentials on the identity. Supply dependency IDs through a local variable file. Complete example grants Contributor at one existing deployment resource group only. This does not grant role-assignment management or Terraform backend blob access. Use a reviewed custom role where Contributor is broader than required.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file=example.tfvars.local
# Review the plan before terraform apply -var-file=example.tfvars.local
```

Set pipeline IDs explicitly; the default authorizes no pipelines. The complete example also needs permission to create the shown role assignment. Protect production service connections with approvals and branch checks before authorizing deployment pipelines. Supply the identity's matching resource, client, tenant, and principal IDs. Configure AzureRM for the identity subscription and the same tenant; cross-subscription role assignments require bootstrap permissions at the target scope.

## Costs and cleanup

No registry, identity, or workload compute is created; existing Azure resources and pipeline agents can incur costs. Destroying this example removes service connection trust and access, including its Azure role assignment; it interrupts dependent pipelines. Import existing resources before adopting them. Never put credentials in committed variable files.

Workload RBAC is created before the connection module enables pipeline access. Azure RBAC propagation can still delay first use; retry the task after propagation rather than broadening permissions. AzureRM is explicitly configured for the supplied identity tenant.
