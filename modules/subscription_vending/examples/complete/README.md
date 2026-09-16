# Existing Subscription Bootstrap

Places an existing subscription under a management group, explicitly registers core providers, and creates monitoring and network bootstrap resource groups.

The provider must target the subscription. Review inherited governance, provider-registration ownership, names, locations, and tags before applying; removing entries later can unregister or destroy managed resources.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
