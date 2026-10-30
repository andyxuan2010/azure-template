# Remove a Terraform-Managed Resource

Remove resources through the Terraform root and state that own them. Do not use legacy `taint` or ad hoc module-directory workflows for routine deletion.

## Before changing configuration

1. Identify the exact resource, module instance, environment, backend key, workspace, and owning configuration. Search for references and downstream consumers.
2. Check service health, data retention, backup and restore requirements, dependencies, soft-delete behavior, and any `prevent_destroy` lifecycle rule. Obtain the normal owner and change approvals.
3. Confirm no concurrent Terraform run is modifying the same state. Preserve state only through the approved protected backup process.

## Plan the removal

1. On a feature branch, remove or disable the resource through its owning configuration, or use a reviewed `moved`/`import` change if ownership is being transferred. Avoid broad targeting as a substitute for correcting configuration.
2. Initialize the correct environment backend and create a fresh plan with the environment's approved variable file.
3. Review the complete plan. Confirm the intended resource is the only destructive change, and verify no shared dependency or data-bearing service is affected. Investigate every unexpected replacement or destroy.
4. Submit the change for peer review and required approvals. Apply only the exact reviewed plan artifact under the repository's deployment controls.
5. Verify the resource and dependent services after apply; record any retained, soft-deleted, or recoverable data and update relevant documentation.

A full `terraform plan -destroy` is only for an isolated state whose entire teardown is explicitly approved. It is not a safe way to remove one resource from a shared root state. See [Terraform State and Recovery](terraform-state-and-recovery.md) and the [Root-Level Module Guide](../20-repository/root-level-modules-guide.md).
