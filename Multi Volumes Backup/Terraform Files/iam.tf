resource "google_project_iam_member" "cloudfunctions_netapp_admin" {
  project = var.project_id
  role    = "roles/netapp.admin"
  member  = "serviceAccount:${google_cloudfunctions_function.netapp_backup_function.service_account_email}"
}

