resource "google_netapp_backup_vault" "test_backup_vault" {
  name = var.backup_vault_name
  location = "us-east4"
  description = "Terraform created vault"
  labels = { 
    "creator": "testuser"
  }
}
/*
resource "google_netapp_backup_vault" "test_backup_vault1" {
  name = "netapp-backup-vaulttwo"
  location = "us-east4"
  description = "Terraform created vault"
  labels = { 
    "creator": "testuser"
  }
}


resource "google_netapp_backup_vault" "test_backup_vault2" {
  name = "netapp-backup-vaultone"
  location = "us-east4"
  description = "Terraform created vault"
  labels = { 
    "creator": "testuser"
  }
}
*/