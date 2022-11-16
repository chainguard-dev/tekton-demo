/**
 * Copyright 2022 The Sigstore Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  type    = string
  default = ""
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Must specify PROJECT_ID variable."
  }
}

variable "cluster_location" {
  type        = string
  description = "Zone or Region to create cluster in."
  default     = "us-central1-a"
}

// Optional values that can be overridden or appended to if desired.
variable "cluster_name" {
  description = "The name of the Kubernetes cluster."
  type        = string
  default     = ""
}

// URLs for Sigstore services
variable "fulcio_url" {
  description = "Fulcio URL"
}

variable "rekor_url" {
  description = "Rekor URL"
}


// Set-up for notification channel for alerting
variable "notification_channel_id" {
  type        = string
  description = "The notification channel ID which alerts should be sent to. You can find this by running `gcloud alpha monitoring channels list`."
}

locals {
  notification_channels = [format("projects/%v/notificationChannels/%v", var.project_id, var.notification_channel_id)]
  qualified_rekor_url   = format("http://%s", var.rekor_url)
  qualified_fulcio_url  = format("http://%s", var.fulcio_url)
}

// Certificate Authority name for alerting
variable "ca_pool_name" {
  description = "Certificate authority pool name"
  type        = string
  default     = "sigstore"
}
