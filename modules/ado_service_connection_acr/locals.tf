locals {
  # Stable across applies, distinct across project/name pairs and endpoint types.
  federated_credential_name = coalesce(var.federated_credential_name, "ado-acr-${substr(sha256("${var.project_id}/${var.name}"), 0, 24)}")
}
