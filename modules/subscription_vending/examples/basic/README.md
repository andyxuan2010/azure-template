# Existing Subscription Placement

Associates an existing subscription with a target management group. The AzureRM provider is explicitly configured for the subscription being governed.

Moving a subscription changes inherited policy and RBAC. Review the effective governance and secure an approval before applying.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
