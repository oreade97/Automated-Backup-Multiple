resource "google_cloud_scheduler_job" "backup_scheduler" {
  name        = "netapp-backup-scheduler"
  schedule    = "0 * * * *"  # Every hour
  time_zone   = "Etc/UTC"
  description = "Triggers the NetApp backup function every hour."

  pubsub_target {
    topic_name = google_pubsub_topic.netapp_backup_topic.id
    data       = base64encode(jsonencode({
      project_id = var.project_id
      region     = var.region
      csv_data   = filebase64("volumes.csv")
    }))
  }
}
