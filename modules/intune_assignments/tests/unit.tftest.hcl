mock_provider "msgraph" {}

variables {
  resources = {
    sample = {
      resource_url = "deviceManagement/deviceConfigurations/example"
      body         = { assignments = [] }
    }
  }
}

run "plan_assignment_action" {
  command = plan

  assert {
    condition     = length(msgraph_resource_action.this) == 1 && msgraph_resource_action.this["sample"].action == "assign"
    error_message = "The assignment action was not planned with the assign operation."
  }
}
