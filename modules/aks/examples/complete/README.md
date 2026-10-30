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

## Cost and risk

- Standard tier adds a per-cluster hourly management fee and the uptime SLA. Nodes are billed per hour by VM size across a system pool of 3 to 6 and a workload pool of 1 to 5 spread over three zones (cross-zone traffic is billed per GB), plus disks and the load balancer.
- Microsoft Defender is billed per vCore, and Container Insights, managed Prometheus metrics and the Dedicated diagnostic tables are billed by data ingested and retained per GB in Log Analytics. All log categories can make ingestion significant.
- The cluster is private, so API access needs a network and DNS path. Network plugin mode, Cilium data plane, node zones and OS SKU cannot change in place and force replacement; the temporary pool name is used for rotation. The stable upgrade channel with weekly Sunday windows (02:00 and 06:00 UTC) means the cluster upgrades itself, so check pod disruption budgets and surge capacity.
