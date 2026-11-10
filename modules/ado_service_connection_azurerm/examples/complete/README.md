# Azure DevOps Azure Resource Manager: complete

Creates a workload-federated service connection and managed-identity trust for an existing Azure subscription. Uses an existing Azure DevOps project and user-assigned identity. This example creates one Contributor assignment at the deployment resource group before it creates the connection and pipeline grants. Use a reviewed custom role when Contributor is broader than needed. It grants neither role-assignment administration nor Terraform state-container data access.

## Prerequisites

- Terraform 1.7+ and an independently authenticated AzureRM/Azure DevOps bootstrap runner.
- Existing project, identity and target subscription; existing pipeline IDs when pipeline access is enabled.
- Permission to create/manage Azure DevOps connections and pipeline authorizations, and federated credentials on the identity. Also requires role-assignment write/delete at the target scope.
- Matching identity resource, client and tenant IDs, plus its principal/object ID for RBAC.

AzureRM is explicitly configured for the identity's subscription and tenant. Cross-subscription workloads require bootstrap permissions at the target scope. The deployment identity needs permissions for the planned Azure resources and separate backend data-plane access where required. Give Terraform state access at the state container rather than the entire subscription. Agents must resolve and reach private state storage and workload endpoints.

## Usage

Run these commands from this example directory. [example.tfvars](example.tfvars) contains documentation values only; replace every placeholder in your local copy. Keep provider credentials in the approved CI/environment authentication mechanism.

```powershell
Copy-Item ./example.tfvars ./example.tfvars.local
# Edit example.tfvars.local with real dependency IDs; leave pipeline_ids empty.
terraform init -backend=false
terraform validate
terraform plan -var-file=example.tfvars.local -out=bootstrap.tfplan
# Review the saved plan before applying it.
terraform apply bootstrap.tfplan
terraform output service_connection_id
terraform output federated_credential_name
```

`-backend=false` is for evaluating this example with local state. Configure an approved secured remote backend before durable/shared use. Never commit local variable files, state, credentials or saved plans. Saved plans can include sensitive data and must be protected.

## Authorizing a pipeline

1. Provision with `pipeline_ids = {}`, as supplied. The module grants no pipeline access in this phase.
2. Use the connection ID to configure the required approvals, branch control, required-template checks and administrator permissions in Azure DevOps. Verify workload RBAC and private connectivity. These controls are managed separately from this example.
3. Set a unique existing pipeline ID for each stable key in your local variable file:

```hcl
pipeline_ids = {
  terraform_apply = 42 # Replace with the actual pipeline ID in the selected project.
}
```

4. Generate and review a new plan, then apply that saved plan. Use `service_connection_name` in the consuming pipeline task. Recheck inherited/manual grants, including all-pipelines grants; Terraform manages only its explicit authorizations.

RBAC propagation may delay first use even after the role assignment exists. Retry after propagation rather than broadening permissions. Run the actual deployment task against a nonproduction resource group. Check the authenticated subscription/tenant, Terraform backend initialization, and a reviewed plan before applying. An Azure login alone does not verify state-container access or private connectivity.

## Service connection and identity names

The sample uses service connection `sc-orders-azurerm-dev-601` and deployment identity `id-orders-deploy-cc-dev-601`. Dev starts at `601`, production at `001`, and QA at `301`; increment the instance for additional connections in the same environment. Change explicit names and IDs together when adapting the sample. The modules do not automatically rename existing dependencies or choose the environment sequence.

## Credential naming and upgrades

The default `federated_credential_name = null` generates a deterministic name from the project, connection name and module type. Different connection names/projects and the ACR/ARM modules use distinct generated names; explicitly supplied names must be unique within an identity. Changing a project or connection name can replace trust.

For an already-deployed connection that used the original default, set `federated_credential_name = "ado-service-connection"` in the local variable file before upgrading to preserve that credential. Review the plan for replacements. Import existing connections/credentials/role assignments before adopting them, and give each resource one Terraform owner.

## Costs and cleanup

No registry, identity or workload compute is created. Existing Azure resources and pipeline agents can incur costs. Destroy removes the connection, its federated credential and managed pipeline authorizations, plus the example role assignment, interrupting dependent pipelines. The caller-owned identity and workload resources remain. Review removal and recovery requirements before running `terraform destroy -var-file=example.tfvars.local`.
