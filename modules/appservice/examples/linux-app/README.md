# Linux Application example

Terraform configuration which creates two Azure Linux Web Apps with the following features:

- Basic SKU (B1)
- HTTPS only
- Azure AD authentication enabled
- System Assigned Identity enabled
- Send logs to Log Analytics Workspace
- Optional Deployment Center integration with Azure Repos (Azure DevOps) using the `deployment_center_*` variables on the `appservice` module
- Optional Linux startup command through `app_command_line`, for example a Python `gunicorn` entrypoint
