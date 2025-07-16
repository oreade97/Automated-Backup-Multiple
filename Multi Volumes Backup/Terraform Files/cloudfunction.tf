resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-netapp-backup-functions"
  location = var.region
}

resource "google_storage_bucket_object" "function_code" {
  name   = "backup"
  bucket = google_storage_bucket.function_bucket.name
  source = "backup.zip"
}

resource "google_cloudfunctions_function" "netapp_backup_function" {
  name        = "create_volume_backup"
  description = "Triggers a backup for Google Cloud NetApp volumes"
  runtime     = "python310"
  region      = var.region
  entry_point = "create_volume_backup"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_code.name

   event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.netapp_backup_topic.name
  }

  available_memory_mb = 256
  timeout             = 300

  environment_variables = {
    VOLUME_NAME = var.volume_name
    REGION      = var.region
    PROJECT_ID  = var.project_id
    BACKUP_VAULT_NAME = var.backup_vault_name
    VOLUME_CSV_PATH = var.volume_path
  }
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.netapp_backup_function.project
  region         = google_cloudfunctions_function.netapp_backup_function.region
  cloud_function = google_cloudfunctions_function.netapp_backup_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}