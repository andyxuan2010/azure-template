# Basic Managed Identity Example

Creates one user-assigned managed identity without federation or role assignments.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-orders-dev"
```

Applying creates a managed identity but grants it no access. Attach the identity to a workload and manage least-privilege authorization in the appropriate owning configuration.

## Cost and risk

- Free: a user-assigned managed identity has no charge, and this example creates nothing else. It grants no access, so it also adds no RBAC risk.
- Risk: the identity's principal and client IDs are tied to the resource. If you delete and recreate it (a name, resource group or location change forces this), every role assignment and federated credential that referenced the old identity is lost and workloads must be re-authorised. Azure also limits the number of identities and federated credentials per subscription and per identity.
