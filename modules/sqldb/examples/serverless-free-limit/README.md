# Serverless Free-Limit SQL Database

Creates an eligible General Purpose serverless configuration with automatic pause and Azure SQL free-limit settings. It intentionally enables a public endpoint for a non-production scenario.

Run `terraform init -backend=false` and `terraform validate` for local validation. Replace the documentation-only firewall address before any plan, confirm current Azure eligibility and regional support, and never use this public pattern for production. Usage beyond the included limit can incur charges according to the selected exhaustion behavior.
