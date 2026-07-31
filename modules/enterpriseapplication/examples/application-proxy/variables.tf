variable "application_id" {
  description = "Application/client ID of the app registration to publish."
  type        = string
}

variable "internal_url" {
  description = "Internal application URL reachable by the Application Proxy connector."
  type        = string
  default     = "https://intranet.example.local/"
}

variable "external_url" {
  description = "Approved external Application Proxy URL."
  type        = string
  default     = "https://intranet-example.msappproxy.net/"
}
