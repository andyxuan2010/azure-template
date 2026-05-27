# Managed Identity Quick Reference

- Required inputs: `name`, `resource_group_name`, `location`
- Optional identity inputs: `federated_identity_credentials`, `role_assignments`
- Primary output: `id`
- Typical dependency chain: `rg -> managedidentity -> functionapp/appservice/aks`
