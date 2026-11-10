# Azure DevOps ACR Docker Registry: basic

Creates a workload-federated service connection and managed-identity trust for an existing ACR. Uses an existing Azure DevOps project and user-assigned identity. This example creates no Azure role assignments. The supplied identity must already have the required workload RBAC.

## Prerequisites

- Terraform 1.7+ and an independently authenticated AzureRM/Azure DevOps bootstrap runner.
- Existing project, identity and registry; existing pipeline IDs when pipeline access is enabled.
- Permission to create/manage Azure DevOps connections and pipeline authorizations, and federated credentials on the identity.
- Matching identity resource, client and tenant IDs.

AzureRM is explicitly configured for the identity's subscription and tenant. Cross-subscription workloads require bootstrap permissions at the target scope. The publishing identity needs push/pull permissions for the registry's RBAC/ABAC mode. Disable registry admin credentials independently. Agents must resolve and reach the registry login and data endpoints; private registries require connected agents and private DNS.

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
  image_build = 42 # Replace with the actual pipeline ID in the selected project.
}
```

4. Generate and review a new plan, then apply that saved plan. Use `service_connection_name` in the consuming pipeline task. Recheck inherited/manual grants, including all-pipelines grants; Terraform manages only its explicit authorizations.

RBAC propagation may delay first use even after the role assignment exists. Retry after propagation rather than broadening permissions. Run the actual image-build pipeline against a nonproduction registry using a unique image tag, then verify a pull of that tag. Confirm the installed Docker task supports workload-federated ACR connections. If it does not, use the separate ARM connection with a compatible Azure CLI task and az acr login.

## Service connection and identity names

The sample uses registry `acrbaccidmpoc`, service connection `sc-orders-acrbaccidmpoc-dev-601`, and publishing identity `id-orders-acrbaccidmpoc-cc-dev-601`. The actual registry name appears in both connection and identity names. Dev starts at `601`, production at `001`, and QA at `301`; increment the instance for additional connections in the same environment. Change explicit names and IDs together when adapting the sample. The modules do not automatically rename existing dependencies or choose the environment sequence.

## Credential naming and upgrades

The default `federated_credential_name = null` generates a deterministic name from the project, connection name and module type. Different connection names/projects and the ACR/ARM modules use distinct generated names; explicitly supplied names must be unique within an identity. Changing a project or connection name can replace trust.

For an already-deployed connection that used the original default, set `federated_credential_name = "ado-service-connection"` in the local variable file before upgrading to preserve that credential. Review the plan for replacements. Import existing connections/credentials/role assignments before adopting them, and give each resource one Terraform owner.

## Costs and cleanup

No registry, identity or workload compute is created. Existing Azure resources and pipeline agents can incur costs. Destroy removes the connection, its federated credential and managed pipeline authorizations, interrupting dependent pipelines. The caller-owned identity and workload resources remain. Review removal and recovery requirements before running `terraform destroy -var-file=example.tfvars.local`.
