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

## Cost and risk

- The control plane uses the Free tier, which has no cluster-management fee and no uptime SLA; you pay for the node VMs (per hour by VM size), their OS disks, and load balancer and outbound traffic. The system pool autoscales from 1 to 3 nodes, so three nodes is the compute ceiling.
- The cluster is private with a system-managed private DNS zone, so kubectl and Kubernetes-provider steps only work from a host with a network and DNS path to the API server. A one-node minimum means no redundancy and brief disruption during upgrades.
- Changing the private cluster setting or the DNS zone mode forces replacement. Creation takes several minutes, and deletion removes the node resource group.
