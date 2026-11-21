terraform {
  required_version = ">= 1.7.0, < 2.0.0"
  required_providers {
    msgraph = {
      source  = "microsoft/msgraph"
      version = ">= 0.3, < 1.0"
    }
  }
}
