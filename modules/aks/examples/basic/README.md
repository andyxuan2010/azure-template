# Basic AKS Example

Creates a private AKS cluster with:

- Microsoft Entra and Azure RBAC;
- local accounts disabled;
- OIDC and Workload Identity;
- a system-assigned control-plane identity;
- an autoscaling system node pool on an existing subnet;
- AKS-managed private DNS.

## Usage

```powershell
terraform init
terraform validate
terraform plan `
  -var="resource_group_name=rg-platform-dev" `
  -var="subnet_id=/subscriptions/.../subnets/snet-aks"
```

Your execution host must have a network and DNS path to the private API server for post-deployment Kubernetes operations.
