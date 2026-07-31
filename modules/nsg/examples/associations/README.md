# NSG Association Ownership Example

Creates an NSG and uses stable map keys to associate one existing subnet and one existing network interface. No custom rules are added, so Azure default NSG rules remain.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="environment.tfvars"
```

Use this pattern only when this state exclusively owns both associations. A subnet or NIC cannot be simultaneously associated with another NSG by another module.
