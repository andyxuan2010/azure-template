# Virtual Hub Azure Firewall Example

Creates a Standard `AZFW_Hub` firewall in an existing Azure Virtual WAN hub. Azure allocates the requested hub public IP count; the module does not create VNet-mode public IP resources.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-vwan-prod" `
  -var="virtual_hub_id=/subscriptions/.../providers/Microsoft.Network/virtualHubs/vhub-prod"
```

The Virtual Hub and Virtual WAN routing intent must already exist or be composed separately. Review secured hub routing, branch and VNet propagation, firewall policy, regional capacity, and cost before apply.
