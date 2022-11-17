variable "DEFAULT_LOCATION" {
  type        = string
  description = "Default location to create resources."
  default     = "us-east-1"
}

variable "CUSTOMER_NAME" {
  type        = string
  description = "Name of the customer for the POV"
  default     = "tekton-demo"
}

variable "OWNER" {
  type        = string
  description = "Who is running the resources"
  default     = "james.strong"
}
