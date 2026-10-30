# Existing Subscription Bootstrap

Places an existing subscription under a management group, explicitly registers core providers, and creates monitoring and network bootstrap resource groups.

The provider must target the subscription. Review inherited governance, provider-registration ownership, names, locations, and tags before applying; removing entries later can unregister or destroy managed resources.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

- Billing: resource group creation and resource provider registration are free, and the subscription already exists. Only resources later placed in it are billed.
- Risk: the management group association applies inherited policy and RBAC at once. Registering Insights, KeyVault, Network and Storage providers affects the whole subscription, can take minutes, and unregistering on destroy can fail while resources of that type exist. The two bootstrap resource groups are deleted on destroy, together with anything inside them.
