//------APIS NEEDED----//

resource "google_project_service" "gcp_resource_manager_api" {
  project            = var.project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
  disable_dependent_services = true
}

locals {
  all_project_services = concat(var.gcp_service_list, [
    "cloudfunctions.googleapis.com", # Enables Cloud Functions
    "cloudbuild.googleapis.com",     # Enables Cloud Build for deployment
    "pubsub.googleapis.com",         # Enables Pub/Sub for triggers
    "netapp.googleapis.com",         # Enables NetApp API for volume management
    "cloudscheduler.googleapis.com"
  ])
}

resource "google_project_service" "enabled_apis" {
  depends_on = [google_project_service.gcp_resource_manager_api]
  project    = var.project_id
  for_each   = toset(local.all_project_services)
  service    = each.key

  disable_on_destroy = false
  disable_dependent_services = true
}