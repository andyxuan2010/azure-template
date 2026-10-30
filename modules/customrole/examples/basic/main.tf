module "route_updater_role" {
  source = "../.."

  name              = "FortiGate Route Updater"
  scope             = var.scope
  assignable_scopes = [var.scope]
  description       = "Read route tables and read, create, or update routes; does not permit deletion or RBAC management."

  actions = [
    "Microsoft.Network/routeTables/read",
    "Microsoft.Network/routeTables/routes/read",
    "Microsoft.Network/routeTables/routes/write",
  ]
}
