module "route_updater_role" {
  source = "../.."

  name              = "FortiGate Route Updater - rg-ba-cc-prod-vfirewall"
  scope             = var.role_definition_scope
  assignable_scopes = [var.role_definition_scope]
  description       = "Read route tables and read, create, or update routes. No route table deletion or RBAC management."

  actions = [
    "Microsoft.Network/routeTables/read",
    "Microsoft.Network/routeTables/routes/read",
    "Microsoft.Network/routeTables/routes/write",
  ]
}

module "route_updater_assignment" {
  source = "../../../roleassignments"

  assignments = {
    fortigate_route_updater = {
      scope              = var.assignment_scope
      role_definition_id = module.route_updater_role.role_definition_resource_id
      principal_id       = var.managed_identity_principal_id
      principal_type     = "ServicePrincipal"
    }
  }
}
