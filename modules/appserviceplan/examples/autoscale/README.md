# Azure Monitor Autoscale Example

Creates a Linux S1 App Service Plan with CPU and memory scale rules, capacity from one to five workers, and email notifications.

This scenario uses Azure Monitor autoscale and therefore leaves Premium platform-managed automatic scaling disabled.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-orders-prod"
```

Replace the example notification address. Applying creates billable plan capacity and autoscale can increase recurring cost; validate thresholds against real workload telemetry, alert delivery, maximum quota, scale-in safety, and cleanup.
