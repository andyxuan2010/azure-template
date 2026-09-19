# Complete AKS Example

Demonstrates a production-oriented private cluster with:

- Standard tier and managed upgrade channels;
- zone-redundant autoscaling system and workload pools;
- Azure CNI Overlay with Cilium;
- Workload Identity and Secrets Store CSI rotation;
- Container Insights, Defender for Containers, managed Prometheus, and diagnostics;
- controlled maintenance windows;
- Microsoft Entra admin and user role assignments.

## Usage

```powershell
terraform init
terraform validate
terraform plan `
  -var="resource_group_name=rg-platform-prod" `
  -var="cluster_name=aks-platform-prod-cc-001" `
  -var="subnet_id=/subscriptions/.../subnets/snet-aks" `
  -var="log_analytics_workspace_id=/subscriptions/.../workspaces/log-platform-prod"
```

Verify regional Kubernetes-version support, VM SKU availability, availability zones, subnet capacity, Azure quota, private DNS, and outbound connectivity before applying.
