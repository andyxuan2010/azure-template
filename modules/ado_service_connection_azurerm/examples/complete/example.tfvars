# Documentation values only. Replace all names and IDs before planning.
# No authentication credentials belong in this file.
organization_url  = "https://dev.azure.com/example"
project_id        = "11111111-1111-1111-1111-111111111111"
name              = "sc-example-azurerm"
subscription_name = "Example subscription"
managed_identity = {
  id        = "/subscriptions/22222222-2222-2222-2222-222222222222/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-azurerm"
  client_id = "33333333-3333-3333-3333-333333333333"
  tenant_id = "44444444-4444-4444-4444-444444444444"
}

# Keep empty until service connection checks and workload RBAC are ready.
pipeline_ids = {}

# Null uses a deterministic project/connection-specific name.
# For a connection deployed with the original default, retain instead:
# federated_credential_name = "ado-service-connection"
federated_credential_name = null

subscription_id = "22222222-2222-2222-2222-222222222222"

# Object/principal ID of the same identity, not its application/client ID.
principal_id                 = "55555555-5555-5555-5555-555555555555"
deployment_resource_group_id = "/subscriptions/22222222-2222-2222-2222-222222222222/resourceGroups/rg-workload"
