# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: customrole
# Description: Creates an Azure custom RBAC role definition.
# Owner: Cloud Center of Excellence (CCOE)
# Repository: CCOE-Azure/azure-template

resource "azurerm_role_definition" "this" {
  role_definition_id = var.role_definition_id
  name               = var.name
  scope              = var.scope
  description        = var.description

  permissions {
    actions          = var.actions
    not_actions      = var.not_actions
    data_actions     = var.data_actions
    not_data_actions = var.not_data_actions
  }

  assignable_scopes = var.assignable_scopes
}
