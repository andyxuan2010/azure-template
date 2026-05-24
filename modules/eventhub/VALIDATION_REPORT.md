# Validation Report

- `terraform fmt -recursive`: passed
- `terraform validate`: passed in an isolated temp-copy module directory after `terraform init -backend=false -upgrade`
- `terraform test`: passed in an isolated temp-copy module directory, 4 plan tests passed
- `git diff --check -- modules/eventhub`: passed

Note: direct repository-path `terraform validate` hit an intermittent AzureRM provider startup timeout in this workspace, so the final validation used a fresh temp-copy path with the same module files.
