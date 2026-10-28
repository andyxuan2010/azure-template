# Management Group With Subscription Placement

Creates a child management group and declaratively places reviewed subscriptions beneath it.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="tenant.tfvars"
```

Moving subscriptions can immediately change inherited policy, RBAC, compliance, and deployment behavior. Use tenant-governance approval, verify the current and target hierarchy, and coordinate every subscription move before apply. The example's `tags` are metadata outputs only.

## Cost and risk

- Free: management groups carry no charge, and moving subscriptions does not change what the resources in them cost.
- Risk: `subscription_ids` moves the listed subscriptions into this group. They immediately inherit its policy assignments, RBAC, and deny effects, which can start blocking deployments or change compliance state, and they lose any inheritance from their previous group. The module treats the list as the full set of members, so a subscription removed from the list leaves the group and falls back to the tenant root group. The caller needs write permission on the group, the parent, and each subscription. Tags are not applied to the management group. Deleting the group fails while it has children or subscriptions.
