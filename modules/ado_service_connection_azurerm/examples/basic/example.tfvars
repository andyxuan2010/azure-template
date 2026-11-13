# Documentation values only. Replace all names and IDs before planning.
# No authentication credentials belong in this file.
# Instance starts: dev 601, prod 001, QA 301; increment subsequent instances.
organization_url  = "https://dev.azure.com/example"
project_id        = "11111111-1111-1111-1111-111111111111"
name              = "sc-orders-azurerm-dev-601"
subscription_name = "Example subscription"
managed_identity = {
  id        = "/subscriptions/22222222-2222-2222-2222-222222222222/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-orders-deploy-cc-dev-601"
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
