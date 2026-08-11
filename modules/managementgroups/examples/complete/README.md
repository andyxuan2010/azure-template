# Management Group With Subscription Placement

Creates a child management group and declaratively places reviewed subscriptions beneath it.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="tenant.tfvars"
```

Moving subscriptions can immediately change inherited policy, RBAC, compliance, and deployment behavior. Use tenant-governance approval, verify the current and target hierarchy, and coordinate every subscription move before apply. The example's `tags` are metadata outputs only.
