resource "google_netapp_backup_vault" "test_backup_vault" {
  name = var.backup_vault_name
  location = "us-east4"
  description = "Terraform created vault"
  labels = { 
    "creator": "testuser"
  }
}
