# Quick Reference

- Module: `roleassignments`
- Key input: `assignments`
- Resolves `principal_name` to Entra group object ID when `principal_id` is not supplied
- Resolves `role_definition_name` to a role definition resource ID when `role_definition_id` is not supplied
- Deduplicates logically identical assignments inside the input set
- Skips creation when a matching role assignment already exists in Azure at the same scope
- Existing Azure assignments are skipped, not automatically imported into Terraform state
