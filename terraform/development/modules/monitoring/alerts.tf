### Cloud SQL Alerts

# Cloud SQL Database Memory Utilization > 90%
resource "google_monitoring_alert_policy" "cloud_sql_memory_utilization" {
  # In the absence of data, incident will auto-close in 7 days
  alert_strategy {
    auto_close = "604800s"
  }

  combiner = "OR"

  conditions {
    condition_threshold {
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }

      comparison      = "COMPARISON_GT"
      duration        = "0s"
      filter          = "metric.type=\"cloudsql.googleapis.com/database/memory/utilization\" resource.type=\"cloudsql_database\""
      threshold_value = "0.9"

      trigger {
        count   = "1"
        percent = "0"
      }
    }

    display_name = "Cloud SQL Database - Memory utilization [MEAN]"
  }

  display_name = "Cloud SQL Database Memory Utilization > 90%"

  documentation {
    content   = "Cloud SQL Database Memory Utilization is >90%. Please increase memory capacity."
    mime_type = "text/markdown"
  }

  enabled               = "true"
  notification_channels = local.notification_channels
  project               = var.project_id
  depends_on            = [google_project_service.service]
}

# Cloud SQL Database Disk Utilization > 95%
resource "google_monitoring_alert_policy" "cloud_sql_disk_utilization" {
  # In the absence of data, incident will auto-close in 7 days
  alert_strategy {
    auto_close = "604800s"
  }

  combiner = "OR"

  conditions {
    condition_threshold {
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }

      comparison      = "COMPARISON_GT"
      duration        = "0s"
      filter          = "metric.type=\"cloudsql.googleapis.com/database/disk/utilization\" resource.type=\"cloudsql_database\""
      threshold_value = "0.95"

      trigger {
        count   = "1"
        percent = "0"
      }
    }

    display_name = "Cloud SQL Database - Disk utilization [MEAN]"
  }

  display_name = "Cloud Sql Disk Utilization > 95%"

  documentation {
    content   = "Cloud SQL disk utilization is > 95%. Please increase capacity. "
    mime_type = "text/markdown"
  }

  enabled               = "true"
  notification_channels = local.notification_channels
  project               = var.project_id
  depends_on            = [google_project_service.service]
}


### KMS Alerts

resource "google_monitoring_alert_policy" "kms_read_request_alert" {
  # In the absence of data, incident will auto-close in 7 days

  alert_strategy {
    auto_close = "604800s"
  }

  combiner = "OR"

  conditions {
    condition_threshold {
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      comparison = "COMPARISON_GT"
      duration   = "0s"
      filter     = "metric.type=\"serviceruntime.googleapis.com/quota/rate/net_usage\" resource.type=\"consumer_quota\" resource.label.\"service\"=\"cloudkms.googleapis.com\" metric.label.\"quota_metric\"=\"cloudkms.googleapis.com/read_requests\""
      // The threshold is 1500/min or 25/s
      threshold_value = "25"

      trigger {
        count   = "1"
        percent = "0"
      }
    }

    display_name = "KMS Read Requests Above Quota"
  }

  display_name = "KMS Read Requests quota usage"

  documentation {
    content   = "KMS Read Requests Above Quota, please see playbook for help."
    mime_type = "text/markdown"
  }

  enabled               = "true"
  notification_channels = local.notification_channels
  project               = var.project_id
  depends_on            = [google_project_service.service]
}

resource "google_monitoring_alert_policy" "kms_crypto_request_alert" {
  # In the absence of data, incident will auto-close in 7 days
  alert_strategy {
    auto_close = "604800s"
  }

  combiner = "OR"

  conditions {
    condition_threshold {
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }

      comparison = "COMPARISON_GT"
      duration   = "300s"
      filter     = "resource.type = \"consumer_quota\" AND resource.labels.service = \"cloudkms.googleapis.com\" AND metric.type = \"serviceruntime.googleapis.com/quota/rate/net_usage\" AND metric.labels.quota_metric = \"cloudkms.googleapis.com/crypto_requests\""
      // The threshold is 60,000/min or 1000/s
      threshold_value = "1000"

      trigger {
        count   = "1"
        percent = "0"
      }
    }

    display_name = "KMS Crypto Requests Rate quota usage"
  }

  display_name = "KMS Crypto Requests Rate Above Quota"

  documentation {
    content   = "KMS Crypto Requests Above Quota, please see playbook for help."
    mime_type = "text/markdown"
  }

  enabled               = "true"
  notification_channels = local.notification_channels
  project               = var.project_id
  depends_on            = [google_project_service.service]
}
