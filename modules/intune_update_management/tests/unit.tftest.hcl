mock_provider "msgraph" {}

variables {
  resources = {
    sample = {
      displayName = "Standards test object"
    }
  }
}

run "plan_graph_configuration" {
  command = plan

  assert {
    condition     = length(msgraph_resource.this) == 1
    error_message = "The configured Graph object was not planned."
  }
}
