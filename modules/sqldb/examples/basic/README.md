# Basic Azure SQL Database

Creates an Entra-only SQL logical server and database with public access disabled and a Private Endpoint attached to an existing SQL Private DNS zone.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, provide the network, DNS, resource group, globally unique server name, and Entra administrator inputs. Configure VNet links and database users separately. Azure SQL and Private Endpoint resources are billable.
